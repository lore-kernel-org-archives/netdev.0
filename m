From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPV6] keeping dst refcnt correctly with using xfrm
Date: Fri, 6 Jun 2003 15:37:18 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606153718.4923bbf9.kazunori@miyazawa.org>
References: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
	<20030605.225547.28789693.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
In-Reply-To: <20030605.225547.28789693.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 05 Jun 2003 22:55:47 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Kazunori Miyazawa <kazunori@miyazawa.org>
>    Date: Fri, 6 Jun 2003 14:49:25 +0900
> 
>    In dst_pop refernce cound of dsts except for last are incremented in
>    dst_clone and decremented in next call dst_pop but last dst refernce
>    count will be never decremented.
>    All dst are held by xfrm_policy and there is no need to touch the
>    refernce count here.
>    
> Ok, so the idea is to hold onto top-level parent DST entry the entire
> time, and this prevents the DST and all it's children from being
> destroyed.  Is this correct?
> 
Yes.
Additionally DST is incremented in the process but never decremented correctly.

Let me explain it. It must be "Don't try to teach your grandmother to suck eggs" :-)

"O" is original dst structure and its refcnt 1 in routing table.
"C" is the child
"DEST" is some paramter in the stack.
(X) after "O" or "C" represents reference count of it.

At first in the result of routing lookup DEST holds "O" with calling dst_hold/dst_clone.
DEST=>O(2)

In xfrm_lookup and related functions the child is created and connect to "O".
Those referenct count are incremented for xfrm_policy holding them.
Then the stack builds up stackable destination like this
DEST=>C(1)
        |=>O(3)

After this the stack regards "C" as the original destination.

I assume the process is datagram. The stack call dst_clone before passing DST
to skb->dst.
skb->dst=DEST=>C(2)
                 |=>O(3)

In dst_pop it increments O with dst_clone and release C with dst_release
skb->dst => C(2)
	      |=>O(3)
call dst_pop....

skb->dst =>O(4) 
DST=>C(1)
       |=>O(4)

The stack done the process and it release DST with dst_release.
"O"'s reference count is decremented in kfree_skb.
skb->dst=DEST=>C(0)
		 |=>O(3)

I hope this helps you.

I don't think I understand whole dst life cycle.
Please teach me if I misunderstand.

BTW, why the stack set "0" to dst refernce count at the initialization.
IMHO it should be "1".

Thank you,

--Kazunori Miyazawa (Yokogawa Electric Corporation)
