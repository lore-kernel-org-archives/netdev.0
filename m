From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] ixgbe: fix truesize calculation when merging active tail
 into lro skb
Date: Tue, 14 Feb 2012 10:47:39 -0800
Message-ID: <4F3AAC4B.7070308@intel.com>
References: <20120213135248.GA23457@sir.fritz.box>   <1329142322.2494.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1329169382.2307.14.camel@jtkirshe-mobl> <4F3A9806.2000102@intel.com> <1329241172.4818.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, Christian Brunner <chb@muc.de>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55822 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab2BNSrk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 13:47:40 -0500
In-Reply-To: <1329241172.4818.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2012 09:39 AM, Eric Dumazet wrote:
> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 09:21 -0800, Alexander Duyck a =C3=
=A9crit :
>
>> The code itself is correct, but the comment isn't.  This code path i=
s
>> applied only to the case where we are not using pages.  The default =
Rx
>> buffer size is actually about 3K when RSC is in use, which means
>> truesize is about 4.25K per buffer.
>>
> Hmm... any reason its not 2.25K per buffer ? (assuming MTU=3D1500)
>
> Do you really need this code in ixgbe_set_rx_buffer_len() ?
>
>                 /*
>                  * Make best use of allocation by using all but 1K of=
 a
>                  * power of 2 allocation that will be used for skb->h=
ead.
>                  */
>                 else if (max_frame <=3D IXGBE_RXBUFFER_3K)
>                         rx_buf_len =3D IXGBE_RXBUFFER_3K;
>                 else if (max_frame <=3D IXGBE_RXBUFFER_7K)
>                         rx_buf_len =3D IXGBE_RXBUFFER_7K;
>                 else if (max_frame <=3D IXGBE_RXBUFFER_15K)
>                         rx_buf_len =3D IXGBE_RXBUFFER_15K;
>                 else
>                         rx_buf_len =3D IXGBE_MAX_RXBUFFER;
>
> Why not using :
> 		rx_buf_len =3D max_frame;
>
> and let kmalloc() do its best ?

The reason for all of this is receive side coalescing.  RSC causes us t=
o
do full buffer size DMAs even if the max frame size is less than the Rx
buffer length.  If RSC is disabled via the NETIF_F_LRO flag then the
default will drop to a 1522 buffer allocation size, and kmalloc can do =
a
2K allocation.

If I am not mistaken, kmalloc only allocates power of 2 sized blocks fo=
r
anything over 256 bytes.  I made the above code change a little while
back when I realized that when RSC was enabled we were setting up a 2K
buffer, which after adding padding and skb_shared_info was 2.375K
resulting in a 4K allocation.  After see that I decided it was better
for us to set the buffer size to 3K which reduced RSC descriptor
processing overhead for the standard case by 50%, and made use of 1K of
the wasted space.

I already have patches in the works that will do away with all of this
code pretty soon anyway, and replace it all with something similar to
our page based packet split path.  It will also end up doing away with
the current RSC code since page based receives end up not needing to be
queued as we are just adding pages to frags.

Thanks,

Alex=20
