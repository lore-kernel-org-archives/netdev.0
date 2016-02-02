From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Tue, 2 Feb 2016 19:29:08 +0100
Message-ID: <56B0F574.5080105@stressinduktion.org>
References: <201601100657.u0A6vk1B025554@mail.home.local>
 <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, socketpair@gmail.com,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: David Herrmann <dh.herrmann@gmail.com>, Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02.02.2016 18:34, David Herrmann wrote:
> Hi
>
> On Sun, Jan 10, 2016 at 7:54 AM, Willy Tarreau <w@1wt.eu> wrote:
>> It is possible for a process to allocate and accumulate far more FDs than
>> the process' limit by sending them over a unix socket then closing them
>> to keep the process' fd count low.
>>
>> This change addresses this problem by keeping track of the number of FDs
>> in flight per user and preventing non-privileged processes from having
>> more FDs in flight than their configured FD limit.
>
> This is not really what this patch does. This patch rather prevents
> processes from having more of their owned *files* in flight than their
> configured FD limit. See below for details..
>
>> Reported-by: socketpair@gmail.com
>> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Mitigates: CVE-2013-4312 (Linux 2.0+)
>> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Signed-off-by: Willy Tarreau <w@1wt.eu>
>> ---
>> v2: add reported-by, mitigates and acked-by.
>>
>> It would be nice if (if accepted) it would be backported to -stable as the
>> issue is currently exploitable.
>> ---
>>   include/linux/sched.h |  1 +
>>   net/unix/af_unix.c    | 24 ++++++++++++++++++++----
>>   net/unix/garbage.c    | 13 ++++++++-----
>>   3 files changed, 29 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index edad7a4..fbf25f1 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -830,6 +830,7 @@ struct user_struct {
>>          unsigned long mq_bytes; /* How many bytes can be allocated to mqueue? */
>>   #endif
>>          unsigned long locked_shm; /* How many pages of mlocked shm ? */
>> +       unsigned long unix_inflight;    /* How many files in flight in unix sockets */
>>
>>   #ifdef CONFIG_KEYS
>>          struct key *uid_keyring;        /* UID specific keyring */
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 45aebd9..d6d7b43 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -1499,6 +1499,21 @@ static void unix_destruct_scm(struct sk_buff *skb)
>>          sock_wfree(skb);
>>   }
>>
>> +/*
>> + * The "user->unix_inflight" variable is protected by the garbage
>> + * collection lock, and we just read it locklessly here. If you go
>> + * over the limit, there might be a tiny race in actually noticing
>> + * it across threads. Tough.
>
> This limit is checked once per transaction. IIRC, a transaction can
> carry 255 files. Thus, it is easy to exceed this limit without any
> race involved.
>
>> + */
>> +static inline bool too_many_unix_fds(struct task_struct *p)
>> +{
>> +       struct user_struct *user = current_user();
>> +
>> +       if (unlikely(user->unix_inflight > task_rlimit(p, RLIMIT_NOFILE)))
>> +               return !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN);
>> +       return false;
>> +}
>> +
>>   #define MAX_RECURSION_LEVEL 4
>>
>>   static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>> @@ -1507,6 +1522,9 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>>          unsigned char max_level = 0;
>>          int unix_sock_count = 0;
>>
>> +       if (too_many_unix_fds(current))
>> +               return -ETOOMANYREFS;
>> +
>
> Ignoring the capabilities, this effectively resolves to:
>
>      if (current_cred()->user->unix_inflight > rlimit(RLIMIT_NOFILE))
>              return -ETOOMANYREFS;
>
> It limits the number of inflight FDs of the *current* user to its *own* limit.
>
> But..
>
>>          for (i = scm->fp->count - 1; i >= 0; i--) {
>>                  struct sock *sk = unix_get_socket(scm->fp->fp[i]);
>>
>> @@ -1528,10 +1546,8 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>>          if (!UNIXCB(skb).fp)
>>                  return -ENOMEM;
>>
>> -       if (unix_sock_count) {
>> -               for (i = scm->fp->count - 1; i >= 0; i--)
>> -                       unix_inflight(scm->fp->fp[i]);
>> -       }
>> +       for (i = scm->fp->count - 1; i >= 0; i--)
>> +               unix_inflight(scm->fp->fp[i]);
>>          return max_level;
>>   }
>>
>> diff --git a/net/unix/garbage.c b/net/unix/garbage.c
>> index a73a226..8fcdc22 100644
>> --- a/net/unix/garbage.c
>> +++ b/net/unix/garbage.c
>> @@ -120,11 +120,11 @@ void unix_inflight(struct file *fp)
>>   {
>>          struct sock *s = unix_get_socket(fp);
>>
>> +       spin_lock(&unix_gc_lock);
>> +
>>          if (s) {
>>                  struct unix_sock *u = unix_sk(s);
>>
>> -               spin_lock(&unix_gc_lock);
>> -
>>                  if (atomic_long_inc_return(&u->inflight) == 1) {
>>                          BUG_ON(!list_empty(&u->link));
>>                          list_add_tail(&u->link, &gc_inflight_list);
>> @@ -132,25 +132,28 @@ void unix_inflight(struct file *fp)
>>                          BUG_ON(list_empty(&u->link));
>>                  }
>>                  unix_tot_inflight++;
>> -               spin_unlock(&unix_gc_lock);
>>          }
>> +       fp->f_cred->user->unix_inflight++;
>
> ..this modifies the limit of the owner of the file you send. As such,
> if you only send files that you don't own, you will continuously bump
> the limit of the file-owner, but never your own. As such, the
> protection above will never fire.
>
> Is this really what this patch is supposed to do? Shouldn't the loop
> in unix_attach_fds() rather check for this:
>
>      if (unlikely(fp->f_cred->user->unix_inflight > nofile &&
>              !file_ns_capable(fp, &init_user_ns, CAP_SYS_RESOURCE) &&
>              !file_ns_capable(fp, &init_user_ns, CAP_SYS_ADMIN)))
>              return -ETOOMANYREFS;
>
> (or keeping capable() rather than file_ns_capable(), depending on the
> wanted semantics)
>
> Furthermore, with this patch in place, a process better not pass any
> file-descriptors to an untrusted process. This might have been a
> stupid idea in the first place, but I would have expected the patch to
> mention this. Because with this patch in place, a receiver of a
> file-descriptor can bump the unix_inflight limit of the sender
> arbitrarily. Did anyone notify the dbus maintainers of this? They
> might wanna document this, if not already done (CC: smcv).
>
> Why doesn't this patch modify "unix_inflight" of the sender rather
> than the passed descriptors? It would require pinning the affected
> user in 'scm' contexts, but that is probably already the case, anyway.
> This way, the original ETOOMANYREFS check would be perfectly fine.
>
> Anyway, can someone provide a high-level description of what exactly
> this patch is supposed to do? Which operation should be limited, who
> should inflight FDs be accounted on, and which rlimit should be used
> on each operation? I'm having a hard time auditing existing
> user-space, given just the scarce description of this commit.

Yes, all your observations are true. I think we need to explicitly
need to refer to the sending socket while attaching the fds.

Good thing is that we don't switch skb->sk while appending the skb to
the receive queue. First quick prototype which is completely untested
(only compile-tested):

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 2a91a0561a4783..d7148ae04b02dd 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -6,8 +6,8 @@
  #include <linux/mutex.h>
  #include <net/sock.h>

-void unix_inflight(struct file *fp);
-void unix_notinflight(struct file *fp);
+void unix_inflight(struct sock *sk, struct file *fp);
+void unix_notinflight(struct sock *sk, struct file *fp);
  void unix_gc(void);
  void wait_for_unix_gc(void);
  struct sock *unix_get_socket(struct file *filp);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 49d5093eb0553a..7bbb4762899924 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1496,7 +1496,7 @@ static void unix_detach_fds(struct scm_cookie 
*scm, struct sk_buff *skb)
  	UNIXCB(skb).fp = NULL;

  	for (i = scm->fp->count-1; i >= 0; i--)
-		unix_notinflight(scm->fp->fp[i]);
+		unix_notinflight(skb->sk, scm->fp->fp[i]);
  }

  static void unix_destruct_scm(struct sk_buff *skb)
@@ -1561,7 +1561,7 @@ static int unix_attach_fds(struct scm_cookie *scm, 
struct sk_buff *skb)
  		return -ENOMEM;

  	for (i = scm->fp->count - 1; i >= 0; i--)
-		unix_inflight(scm->fp->fp[i]);
+		unix_inflight(skb->sk, scm->fp->fp[i]);
  	return max_level;
  }

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 8fcdc2283af50c..874c42161717f0 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -116,7 +116,7 @@ struct sock *unix_get_socket(struct file *filp)
   * descriptor if it is for an AF_UNIX socket.
   */

-void unix_inflight(struct file *fp)
+void unix_inflight(struct sock *sk, struct file *fp)
  {
  	struct sock *s = unix_get_socket(fp);

@@ -133,11 +133,11 @@ void unix_inflight(struct file *fp)
  		}
  		unix_tot_inflight++;
  	}
-	fp->f_cred->user->unix_inflight++;
+	sk->sk_socket->file->f_cred->user->unix_inflight++;
  	spin_unlock(&unix_gc_lock);
  }

-void unix_notinflight(struct file *fp)
+void unix_notinflight(struct sock *sk, struct file *fp)
  {
  	struct sock *s = unix_get_socket(fp);

@@ -152,7 +152,7 @@ void unix_notinflight(struct file *fp)
  			list_del_init(&u->link);
  		unix_tot_inflight--;
  	}
-	fp->f_cred->user->unix_inflight--;
+	sk->sk_socket->file->f_cred->user->unix_inflight++;
  	spin_unlock(&unix_gc_lock);
  }
