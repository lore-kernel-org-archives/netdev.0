From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: pointers in the sk_buff structure.
Date: Fri, 4 Feb 2005 13:06:29 +0100
Message-ID: <20050204120629.GB12630@xi.wantstofly.org>
References: <d50018af05020314451010c5eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: sudeep list <sudeep.list@gmail.com>
Content-Disposition: inline
In-Reply-To: <d50018af05020314451010c5eb@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Feb 03, 2005 at 03:45:15PM -0700, sudeep list wrote:

> hello,

Hi,


> I figured that the pointer sk_buff->tail points to the end of data in
> the buffer attached to the sk_buff. What does the pointer sk_buff->end
> point to ?
> 
> Is there any data that lies between the two pointers, or they are two
> pointers to the same address (end of data in the buffer area) ?

This is a snippet from some docs on the subject I wrote a while ago,
hope it helps.  I should polish it up and submit it for inclusion.


2. The sk_buff structure.

The sk_buff structure ('skb') is actually only used for storing the
metadata corresponding to a packet.  The packet's data is not stored
inside the sk_buff structure itself, but in a separate buffer that is
pointed to by skb->head.  The skb->end member points one byte past the
end of this data buffer.

An important design requirement for sk_buffs is being able to add data
at the end as well as at the front of the packet.  As a packet travels
downwards through the network stack, each layer will usually want to
add its own header in front of the packet, and it would be nice if we
could avoid reallocating and/or copying the entire data portion of the
packet around to make more space at the front of the buffer every time
we want to do this.

To achieve this goal, the packet data is not necessarily stored at the
front of the data buffer, but some space between the front of the buffer
and the front of the packet is left unused.  skb->data and skb->tail
are two extra pointers that point to the beginning and one byte past
the end of the currently used portion of the data buffer, respectively.
Both are guaranteed to point somewhere within the data buffer.
('skb->head <= skb->data <= skb->tail <= skb->end')

        +----------+-------------------------------------+--------------+
        | headroom | packet data                         | tailroom     |
        +----------+-------------------------------------+--------------+
        ^          ^ skb->data                           ^     skb->end ^
        |                                                |
        + skb->head                                      + skb->tail

The function skb_headroom(skb) calculates 'skb->data - skb->head', and
indicates how many bytes we can add to the front of the packet without
having to reallocate the buffer.  Similarly, skb_tailroom(skb) calculates
'skb->end - skb->tail' and indicates how many bytes we can add to the
end of the packet before having to reallocate.

Adding data to and removing data from the front of the buffer is done
with skb_push and skb_pull, respectively.  These wrappers do some sanity
checks to make sure the relevant constraints on the four pointers are
maintained.

When an sk_buff is allocated by alloc_skb, skb->{head,data,tail} are all
initialised to point to the start of the data buffer.  Depending on what
the skb will be used for, the caller will usually want to reserve some
headroom in anticipation of expansion of the data buffer towards the
front.  This is done by calling skb_reserve().
