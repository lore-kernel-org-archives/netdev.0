From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix
 sockets
Date: Tue, 2 Feb 2016 22:55:03 +0100
Message-ID: <56B125B7.6020702@stressinduktion.org>
References: <201601100657.u0A6vk1B025554@mail.home.local>
 <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
 <56B0F574.5080105@stressinduktion.org>
 <CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com>
 <56B11278.8000805@stressinduktion.org> <20160202203929.GC25828@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	???????? ?????????????????? <socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160202203929.GC25828@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Willy,

On 02.02.2016 21:39, Willy Tarreau wrote:
> On Tue, Feb 02, 2016 at 09:32:56PM +0100, Hannes Frederic Sowa wrote:
>> But "struct pid *" in unix_skb_parms should be enough to get us to
>> corresponding "struct cred *" so we can decrement the correct counter
>> during skb destruction.
>>
>> So:
>>
>> We increment current task's unix_inflight and also check the current
>> task's limit during attaching fds to skbs and decrement the inflight
>> counter via "struct pid *". This looks like it should work.
>
> I like it as well, the principle sounds sane.
>
>>> That way it's always the person who actually does the send (rather
>>> than the opener of the socket _or_ the opener of the file that gets
>>> passed around) that gets credited, and thanks to the cred pointer we
>>> can then de-credit them properly.
>>
>> Exactly, I try to implement that. Thanks a lot!
>
> Thanks to you Hannes, I appreciate that you work on it, it would take
> much more time to me to dig into this.

I slightly tested the attached patch. If you have the original 
reproducer available could you also give it a try? Unfortunately I 
currently don't find it and am limited in time this evening.

Thanks a lot,
Hannes

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 2a91a0561a4783..4567dbe04f274d 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -6,8 +6,8 @@
  #include <linux/mutex.h>
  #include <net/sock.h>

-void unix_inflight(struct file *fp);
-void unix_notinflight(struct file *fp);
+void unix_inflight(const struct cred *cred, struct file *fp);
+void unix_notinflight(const struct cred *cred, struct file *fp);
  void unix_gc(void);
  void wait_for_unix_gc(void);
  struct sock *unix_get_socket(struct file *filp);
diff --git a/include/net/scm.h b/include/net/scm.h
index 262532d111f51e..8bf7d496545bf8 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -21,6 +21,7 @@ struct scm_creds {
  struct scm_fp_list {
  	short			count;
  	short			max;
+	const struct cred	*cred;
  	struct file		*fp[SCM_MAX_FD];
  };

diff --git a/net/core/scm.c b/net/core/scm.c
index 14596fb3717270..6b02b574e283f6 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -87,6 +87,7 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct 
scm_fp_list **fplp)
  		*fplp = fpl;
  		fpl->count = 0;
  		fpl->max = SCM_MAX_FD;
+		fpl->cred = NULL;
  	}
  	fpp = &fpl->fp[fpl->count];

@@ -107,6 +108,10 @@ static int scm_fp_copy(struct cmsghdr *cmsg, struct 
scm_fp_list **fplp)
  		*fpp++ = file;
  		fpl->count++;
  	}
+
+	if (fpl->cred)
+		put_cred(fpl->cred);
+	fpl->cred = get_current_cred();
  	return num;
  }

@@ -119,6 +124,7 @@ void __scm_destroy(struct scm_cookie *scm)
  		scm->fp = NULL;
  		for (i=fpl->count-1; i>=0; i--)
  			fput(fpl->fp[i]);
+		put_cred(fpl->cred);
  		kfree(fpl);
  	}
  }
@@ -336,6 +342,7 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
  		for (i = 0; i < fpl->count; i++)
  			get_file(fpl->fp[i]);
  		new_fpl->max = new_fpl->count;
+		new_fpl->cred = get_cred(fpl->cred);
  	}
  	return new_fpl;
  }
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 49d5093eb0553a..ba5058682419ba 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1496,7 +1496,7 @@ static void unix_detach_fds(struct scm_cookie 
*scm, struct sk_buff *skb)
  	UNIXCB(skb).fp = NULL;

  	for (i = scm->fp->count-1; i >= 0; i--)
-		unix_notinflight(scm->fp->fp[i]);
+		unix_notinflight(scm->fp->cred, scm->fp->fp[i]);
  }

  static void unix_destruct_scm(struct sk_buff *skb)
@@ -1561,7 +1561,7 @@ static int unix_attach_fds(struct scm_cookie *scm, 
struct sk_buff *skb)
  		return -ENOMEM;

  	for (i = scm->fp->count - 1; i >= 0; i--)
-		unix_inflight(scm->fp->fp[i]);
+		unix_inflight(scm->fp->cred, scm->fp->fp[i]);
  	return max_level;
  }

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 8fcdc2283af50c..30b03e7dddd547 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -116,7 +116,7 @@ struct sock *unix_get_socket(struct file *filp)
   * descriptor if it is for an AF_UNIX socket.
   */

-void unix_inflight(struct file *fp)
+void unix_inflight(const struct cred *cred, struct file *fp)
  {
  	struct sock *s = unix_get_socket(fp);

@@ -133,11 +133,11 @@ void unix_inflight(struct file *fp)
  		}
  		unix_tot_inflight++;
  	}
-	fp->f_cred->user->unix_inflight++;
+	cred->user->unix_inflight++;
  	spin_unlock(&unix_gc_lock);
  }

-void unix_notinflight(struct file *fp)
+void unix_notinflight(const struct cred *cred, struct file *fp)
  {
  	struct sock *s = unix_get_socket(fp);

@@ -152,7 +152,7 @@ void unix_notinflight(struct file *fp)
  			list_del_init(&u->link);
  		unix_tot_inflight--;
  	}
-	fp->f_cred->user->unix_inflight--;
+	cred->user->unix_inflight--;
  	spin_unlock(&unix_gc_lock);
  }
