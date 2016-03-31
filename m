From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] tun, bpf: fix suspicious RCU usage in tun_{attach,detach}_filter
Date: Thu, 31 Mar 2016 13:35:21 +0200
Message-ID: <56FD0B79.5020007@iogearbox.net>
References: <755ee9ec1f6d2229be41806964b372548e4b7586.1459382574.git.daniel@iogearbox.net> <20160331011840.GA50846@ast-mbp.thefacebook.com> <20160331050115.GA21665@unicorn.suse.cz> <20160331050808.GA56499@ast-mbp.thefacebook.com> <20160331052232.GB21665@unicorn.suse.cz> <20160331054301.GA57227@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sasha.levin@oracle.com, jslaby@suse.cz,
	eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46701 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbcCaLfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 07:35:32 -0400
In-Reply-To: <20160331054301.GA57227@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2016 07:43 AM, Alexei Starovoitov wrote:
> On Thu, Mar 31, 2016 at 07:22:32AM +0200, Michal Kubecek wrote:
>> On Wed, Mar 30, 2016 at 10:08:10PM -0700, Alexei Starovoitov wrote:
>>> On Thu, Mar 31, 2016 at 07:01:15AM +0200, Michal Kubecek wrote:
>>>> On Wed, Mar 30, 2016 at 06:18:42PM -0700, Alexei Starovoitov wrote:
>>>>>
>>>>> kinda heavy patch to shut up lockdep.
>>>>> Can we do
>>>>> old_fp = rcu_dereference_protected(sk->sk_filter,
>>>>>                                  sock_owned_by_user(sk) || lockdep_rtnl_is_held());
>>>>> and it always be correct?
>>>>> I think right now tun is the only such user, but if it's correct
>>>>> for tun, it's correct for future users too. If not correct then
>>>>> not correct for tun either.
>>>>> Or I'm missing something?
>>>>
>>>> Already discussed here:
>>>>
>>>>    http://thread.gmane.org/gmane.linux.kernel/2158069/focus=405853
>>>
>>> I saw that. My point above was challenging 'less accurate' part.
>>>
>> Daniel's point was that lockdep_rtnl_is_held() does not mean "we hold
>> RTNL" but "someone holds RTNL" so that some other task holding RTNL at
>> the moment could make the check happy even when called by someone
>> supposed to own the socket.
>
> Of course... and that is the case for all rtnl_dereference() calls...
> yet we're not paranoid about it.

Sure, but the rtnl case is a bit different, no? In the sense that there's
only one global mutex. So, imho, I don't think it's appropriate to relax
the current rcu_dereference_protected() check for the socket case _just_
in order to silence the tun case warning, if we _can_ actually do better
than this w/o much effort.

I thought about some alternatives if we really don't want to change the
API code like this: We could change the rcu_dereference_protected() just
into a rcu_dereference(), but with the trade-off of not having lockdep
which is probably not really what we want. We could hack the tun case to
create some 'fake' ownership by setting sk->sk_lock.owned, but this seems
very hacky imho, and messing around with sk_lock details that shouldn't
be messed with. Or, as in the other thread mentioned, we could add a flag
like below to mark the socket that it doesn't need to be locked in the
expected way. That diff works as well, is smaller, and the flag could
perhaps be reused in other cases, too. Downside is that we burn a socket
flag, but as it's not uapi, it's not set in stone and can still be changed
should we get into a shortage of bits in future. Have no strong opinion
whether this seems better or not.

Thanks,
Daniel

  drivers/net/tun.c  | 1 +
  include/net/sock.h | 8 ++++++++
  net/core/filter.c  | 7 ++++---
  3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950..8dc7d3e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2252,6 +2252,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
  	INIT_LIST_HEAD(&tfile->next);

  	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
+	sock_set_flag(&tfile->sk, SOCK_EXTERNAL_OWNER);

  	return 0;
  }
diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e0..8d90673 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -720,6 +720,9 @@ enum sock_flags {
  		     */
  	SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
  	SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
+	SOCK_EXTERNAL_OWNER, /* External locking (e.g. RTNL) is used instead
+			      * of sk_lock for control path.
+			      */
  };

  #define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
@@ -1330,6 +1333,11 @@ static inline void sock_release_ownership(struct sock *sk)
  	sk->sk_lock.owned = 0;
  }

+static inline bool sock_owned_externally(const struct sock *sk)
+{
+	return sk->sk_flags & (1UL << SOCK_EXTERNAL_OWNER);
+}
+
  /*
   * Macro so as to not evaluate some arguments when
   * lockdep is not enabled.
diff --git a/net/core/filter.c b/net/core/filter.c
index 4b81b71..828274e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1166,9 +1166,9 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
  	}

  	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   sock_owned_by_user(sk) ||
+					   sock_owned_externally(sk));
  	rcu_assign_pointer(sk->sk_filter, fp);
-
  	if (old_fp)
  		sk_filter_uncharge(sk, old_fp);

@@ -2259,7 +2259,8 @@ int sk_detach_filter(struct sock *sk)
  		return -EPERM;

  	filter = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+					   sock_owned_by_user(sk) ||
+					   sock_owned_externally(sk));
  	if (filter) {
  		RCU_INIT_POINTER(sk->sk_filter, NULL);
  		sk_filter_uncharge(sk, filter);
-- 
1.9.3
