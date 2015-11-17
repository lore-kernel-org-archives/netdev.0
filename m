From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Tue, 17 Nov 2015 11:08:22 -0500
Message-ID: <564B50F6.4030203@akamai.com>
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
 <5646617C.9080506@akamai.com>
 <87vb93dsfc.fsf@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <87vb93dsfc.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/15/2015 01:32 PM, Rainer Weikusat wrote:

> 
> That was my original idea. The problem with this is that the code
> starting after the _lock and running until the main code path unlock has
> to be executed in one go with the other lock held as the results of the
> tests above this one may become invalid as soon as the other lock is
> released. This means instead of continuing execution with the send code
> proper after the block in case other became receive-ready between the
> first and the second test (possible because _dgram_recvmsg does not
> take the unix state lock), the whole procedure starting with acquiring
> the other lock would need to be restarted. Given sufficiently unfavorable
> circumstances, this could even turn into an endless loop which couldn't
> be interrupted. (unless code for this was added). 
> 

hmmm - I think we can avoid it by doing the wakeup from the write path
in the rare case that the queue has emptied - and avoid the double lock. IE:

                unix_state_unlock(other);
                unix_state_lock(sk);
                err = -EAGAIN;
                if (unix_peer(sk) == other) {
                       unix_dgram_peer_wake_connect(sk, other);
                       if (skb_queue_len(&other->sk_receive_queue) == 0)
                               need_wakeup = true;
                }
                unix_state_unlock(sk);
                if (need_wakeup)
                        wake_up_interruptible_poll(sk_sleep(sk), POLLOUT
| POLLWRNORM | POLLWRBAND);
                goto out_free;


Thanks,

-Jason
