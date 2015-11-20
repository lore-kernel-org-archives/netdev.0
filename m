From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue (w/
 Fixes:)
Date: Fri, 20 Nov 2015 11:03:36 -0500
Message-ID: <564F4458.8050309@akamai.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
 <20151012120249.GB16370@unicorn.suse.cz>
 <1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
 <CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
 <563CC002.5050307@akamai.com>
 <87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
 <87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
 <877flp34fl.fsf@doppelsaurus.mobileactivedefense.com>
 <87a8qhspfm.fsf@doppelsaurus.mobileactivedefense.com>
 <876111wpza.fsf@doppelsaurus.mobileactivedefense.com>
 <87ziydvasn.fsf_-_@doppelsaurus.mobileactivedefense.com>
 <87d1v57dif.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Paul Moore <paul@paul-moore.com>, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com,
	netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1v57dif.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2015 06:52 PM, Rainer Weikusat wrote:

[...]

> @@ -1590,21 +1718,35 @@ restart:
>  			goto out_unlock;
>  	}
>  
> -	if (unix_peer(other) != sk && unix_recvq_full(other)) {
> -		if (!timeo) {
> +	if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
> +		if (timeo) {
> +			timeo = unix_wait_for_peer(other, timeo);
> +
> +			err = sock_intr_errno(timeo);
> +			if (signal_pending(current))
> +				goto out_free;
> +
> +			goto restart;
> +		}
> +
> +		if (unix_peer(sk) != other ||
> +		    unix_dgram_peer_wake_me(sk, other)) {
>  			err = -EAGAIN;
>  			goto out_unlock;
>  		}

Hi,

So here we are calling unix_dgram_peer_wake_me() without the sk lock the first time
through - right? In that case, we can end up registering on the queue of other for
the callback but we might have already connected to a different remote. In that case,
the wakeup will crash if 'sk' has freed in the meantime.

Thanks,

-Jason
