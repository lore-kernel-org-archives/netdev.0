From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering
 infrastructure
Date: Mon, 21 Jan 2013 13:45:34 +0200
Message-ID: <20130121134534.78032a54.shmulik.ladkani@gmail.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
	<1358360289-23249-3-git-send-email-vyasevic@redhat.com>
	<CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com>
	<50FC307A.5090003@redhat.com>
	<20130120113825.759b4a58@nehalam.linuxnetplumber.net>
	<50FC9F03.5000102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?B?TWljaGHFgiBN?= =?UTF-8?B?aXJvc8WCYXc=?=
	<mirqus@gmail.com>, netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com
To: vyasevic@redhat.com, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36410 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964Ab3AULpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 06:45:45 -0500
Received: by mail-wg0-f48.google.com with SMTP id 16so355002wgi.27
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 03:45:43 -0800 (PST)
In-Reply-To: <50FC9F03.5000102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Sun, 20 Jan 2013 20:50:59 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> On 01/20/2013 02:38 PM, Stephen Hemminger wrote:
> > Let's assume the people that really want this feature are using a lot
> > of vlan's. i.e n = 1000 or so. A bitmap is O(1). Any hash list would
> > incur a just a big memory penalty for the list head. In other words
> > a full bitmap is 4096 bits = 512 bytes.  If you use hash list,
> > then the equivalent memory size would be only 64 list heads, therefore
> > a bitmap is a better choice than a hlist.
> >
> 
> This was the approach taken in the RFC v1 of this series.  What I found 
> was that while it worked very well as far as speed goes, it was a bit 
> cumbersome to extend it to support pvids and it would completely fall
> on its face for egress policy that Shmulik is suggesting.  So any kinds 
> of extensions to it were tough to do.

I don't see why this is the case.

How about (sketch only, names questionable...):

struct net_bridge {
+	unsigned long vlan_port_membership_bitmap[VLAN_N_VID][PORT_BITMAP_LEN];
+	unsigned long vlan_port_egress_policy_bitmap[VLAN_N_VID][PORT_BITMAP_LEN];
}

(can be alloc'ed instead of the arrays being part of the struct)

struct net_bridge_port {
+	u16 pvid;
};

Allows O(1) to the query "is port P member of vlan V".
Allows O(1) to the query "should vlan V egress tagged/untagged on port P".

I guess this might simplify the data structures involved, avoiding the
refcounts, etc...

The penaties are:
 - memory
 - aesthetics (?)
 - inefficient if query is "give me the entire list of VLANs port P is
   member of". But do we have such a query in bridge's code?

You say it went cumbersome. Am I missing something?

BTW, altenatively, you may:

struct net_bridge_port {
+	unsigned long vlan_membership_bitmap[BITS_TO_LONGS(VLAN_N_VID)];
+	unsigned long vlan_egress_policy_bitmap[BITS_TO_LONGS(VLAN_N_VID)];
+	u16 pvid;
};

Which also allows O(1) to "is port 'nbp' member of vlan V".

Difference:
- For the membership structure:
  former (within net_bridge) uses 4096 * BR_MAX_PORTS bits,
  latter (within net_bridge_port) uses NumOfNBPs * 4096 bits 
- better aesthetics (?)

Regards,
Shmulik
