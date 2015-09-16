From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH] net: bridge: fix for bridging 802.1Q without
 REORDER_HDR
Date: Wed, 16 Sep 2015 12:41:11 +0200
Message-ID: <20150916104111.GA24212@orbit.nwl.cc>
References: <1441999323-29381-1-git-send-email-phil@nwl.cc>
 <20150911122445.53cdfbcf@urahara>
 <20150911202033.GE7029@orbit.nwl.cc>
 <55F71016.7060202@gmail.com>
 <20150914200648.GH30501@orbit.nwl.cc>
 <55F83539.2050706@gmail.com>
 <20150915181755.GA6902@orbit.nwl.cc>
 <55F8D5B9.5030306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	greearb@candelatech.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:44595 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbbIPKlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 06:41:13 -0400
Content-Disposition: inline
In-Reply-To: <55F8D5B9.5030306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 10:36:41PM -0400, Vlad Yasevich wrote:
> On 09/15/2015 02:17 PM, Phil Sutter wrote:
> > On Tue, Sep 15, 2015 at 11:11:53AM -0400, Vlad Yasevich wrote:
> >> On 09/14/2015 04:06 PM, Phil Sutter wrote:
> >>> On Mon, Sep 14, 2015 at 02:21:10PM -0400, Vlad Yasevich wrote:
> >>>> On 09/11/2015 04:20 PM, Phil Sutter wrote:
> >>>>> On Fri, Sep 11, 2015 at 12:24:45PM -0700, Stephen Hemminger wrote:
> >>>>>> On Fri, 11 Sep 2015 21:22:03 +0200
> >>>>>> Phil Sutter <phil@nwl.cc> wrote:
> >>>>>>
> >>>>>>> When forwarding packets from an 802.1Q interface with REORDER_HDR set to
> >>>>>>> zero, the VLAN header previously inserted by vlan_do_receive() needs to
> >>>>>>> be stripped from the packet and the mac_header adjustment undone,
> >>>>>>> otherwise a tagged frame with first four bytes missing will be
> >>>>>>> transmitted.
> >>>>>>>
> >>>>>>> Signed-off-by: Phil Sutter <phil@nwl.cc>
> >>>>>>> ---
> >>>>>>>  net/bridge/br_input.c | 10 ++++++++++
> >>>>>>>  1 file changed, 10 insertions(+)
> >>>>>>>
> >>>>>>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> >>>>>>> index f921a5d..e4e3fc7 100644
> >>>>>>> --- a/net/bridge/br_input.c
> >>>>>>> +++ b/net/bridge/br_input.c
> >>>>>>> @@ -288,6 +288,16 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
> >>>>>>>  	}
> >>>>>>>  
> >>>>>>>  forward:
> >>>>>>> +	if (is_vlan_dev(skb->dev) &&
> >>>>>>> +	    !(vlan_dev_priv(skb->dev)->flags & VLAN_FLAG_REORDER_HDR)) {
> >>>>>>> +		unsigned int offset = skb->data - skb_mac_header(skb);
> >>>>>>> +
> >>>>>>> +		skb_push(skb, offset);
> >>>>>>> +		memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
> >>>>>>> +		skb->mac_header += VLAN_HLEN;
> >>>>>>> +		skb_pull(skb, offset);
> >>>>>>> +		skb_reset_mac_len(skb);
> >>>>>>> +	}
> >>>>>>>  	switch (p->state) {
> >>>>>>>  	case BR_STATE_FORWARDING:
> >>>>>>>  		rhook = rcu_dereference(br_should_route_hook);
> >>>>>>
> >>>>>> Thanks for finding this. Is this a new thing or has it always been there?
> >>>>>
> >>>>> Sorry, I didn't check if this is a regression or not. Seen initially
> >>>>> with RHEL7's kernel-3.10.0-229.7.2, which due to the massive backporting
> >>>>> is by far not as old as it might seem. But it's surely not a brand new
> >>>>> problem of net-next or so.
> >>>>>
> >>>>> Since nowadays no sane mind touches REORDER_HDR (there was originally a
> >>>>> bug in NetworkManager which defaulted this to 0), it may very well be
> >>>>> there for a long time already.
> >>>>>
> >>>>>> Sorry, this looks so special case it doesn't seem like a good idea.
> >>>>>> Something is broken in VLAN handling if this is required.
> >>>>>
> >>>>> It is so ugly, I wish I had found a better way to fix the problem. Well,
> >>>>> maybe I miss something:
> >>>>>
> >>>>> - packet enters __netif_receive_skb_core():
> >>>>>   - skb->protocol is set to ETH_P_8021Q, so:
> >>>>>     - packet is untagged
> >>>>>     - skb->vlan_tci set
> >>>>>     - skb->protocol set to 'real' protocol
> >>>>>   - skb_vlan_tag_present(skb) == true, so:
> >>>>>     - vlan_do_receive() is called:
> >>>>>       - tags the packet again
> >>>>>       - zeroes vlan_tci
> >>>>>     - goto another_round
> >>>>> - __netif_receive_skb_core(), round 2:
> >>>>>   - skb->protocol is not ETH_P_8021Q -> no untagging
> >>>>>   - skb_vlan_tag_present(skb) == false -> no vlan_do_receive()
> >>>>>   - rx_handler handler (== br_handle_frame) is called
> >>>>>
> >>>>> IMO the root of all evil is the existence of REORDER_HDR itself. It
> >>>>> causes an skb which should have been untagged to being passed along with
> >>>>> VLAN header present and code dealing with it needs to clean up the mess.
> >>>>
> >>>> So the problem here appears the be the code the in br_dev_queue_push_xmit().
> >>>> It assumes that MAC_HLEN worth of data has been removed from the skb,
> >>>> which is normal in case of normal VLAN processing.  However, without
> >>>> REORDER_HEADER set this is no longer the case.  In this case, the ethernet
> >>>> header is shifted 4 bytes, and when we push the it back we miss the 4 bytes
> >>>> of the destination mac address...
> >>>
> >>> Please note that vlan_do_receive() also inserts the VLAN header in
> >>> between ethernet header and IP header, therefore:
> >>>
> >>>> I wonder if it would be safe to just use skb->mac_len.
> >>>
> >>> Given this works, the bridge would still forward a tagged frame which
> >>> should have been untagged in the first place.
> >>>
> >>> I just wondered where this added VLAN header is dropped if the interface
> >>> does not belong to a bridge, but then realized that further packet
> >>> processing simply ignores the ethernet header (and everything following
> >>> it). So unless I forget something, this should indeed be a
> >>> bridge-specific problem.
> >>>
> >>
> >> Looks like macvtap is also susceptible to this problem.  It seems to be a bad
> >> idea to allow any upper device configuration on top of a REORDER_HDR=0 vlan.
> >> It is also not enough to just check is_vlan_dev(skb->dev) because vlan may be at
> >> lower in the device stack.
> > 
> > Oh well. Apart from implementing workarounds for this workaround, maybe
> > there is another approach:
> > 
> > If I see this correctly, the VLAN header is only interesting for users
> > looking directly at the packet, like PACKET or RAW sockets. All others
> > either ignore the MAC layer or expect it to be untagged (which is the
> > purpose of reading packets from a VLAN interface).
> 
> This isn't always the case either.  For instance old dhcp using packet socket
> don't want the vlan header and in fact don't work when vlan header is present.

Understood. Is this working with a current kernel? I couldn't find code
dealing with this situation in af_packet.c. OTOH, this email indicates
the opposite is the case:
http://marc.info/?l=linux-vlan&m=98273688827768
So maybe REORDER_HDR has been added to allow for DHCP over VLAN by
setting it to 1? Also, quoting this site:
https://www.candelatech.com/~greear/vlan.html

"Optional header-reordering, to make the VLAN interface look JUST LIKE
an Ethernet interface. This fixes some problems with DHCPd and anything
else that uses a SOCK_PACKET socket. Default setting is off, which works
for every other protocol I know about, and is slightly faster."

This says:
- Header-reordering (i.e. REORDER_HDR) was off by default back then.
- At some point it was more performant to leave it off, which is clearly
  not the case anymore as with REORDER_HDR==0, the tag is first stripped
  and then added again.

Ben, do you have any memories how the dark ages of Linux VLANs were
like?

> I've actually spent some time searching for users of these vlan devices
> (the ones that clear REORDER_HDR) and haven't found any yet...

That's at least something, although I fear anything can be found if one
just searches long enough. :)

> > Users wanting to read these (re-)tagged frames need to attach to the
> > interface where they occur directly. Expecting to see the VLAN header
> > when sniffing on a bridge interface which has the problematic VLAN
> > interface enslaved can sanely be denied, right?
> > 
> 
> I really want to agree with you here, but finding it hard to do due to
> the long history of having the REORDER_HDR in the implementation.  I
> am guessing that it was added for some specific use cases and has remained
> so that those use case will not break.
> 
> However, having said this, I think there is some serious breakage with
> REORDER_HDR=0 configs.  In addition to what you've noticed,  q-in-q
> configuration also do not work correctly because skb_reorder_vlan_header()
> assumes that there is no vlan header prior to the current one.
> 
> > So wouldn't it be the easier option to patch up these users interested
> > in the data to insert the tag there instead of having it added by
> > default and deciding where (and how) to get rid of it again?
> >
> 
> How do you tell if the user is interested in the tag or not?  Say
> we fix q-in-q config and we have a q-in-q setup.  The point of inspection
> is the inner vlan device.  Is the user interested in both vlan tags or just
> one?  What if the the point of inspection is some device higher in stack then
> a vlan?

I don't really see a problem here, but maybe I miss the point. Let's
assum the following setup:

| eth0 - vlan23@eth0 - vlan23.42@vlan23 - br0

So br0 contains vlan23.42, which runs on top of vlan23 and so on.
REORDER_HDR=0 never applies to packets passed upwards in the stack,
otherwise if vlan23.42 has it unset, br0 would forward tagged frames.
Which is pointless, as then one could just enslave vlan23 into br0 to
achieve the same effect.

A user sniffing eth0 always sees both VLAN tags, just as they are on the
wire.

Sniffing vlan23 shows both tags if REORDER_HDR(vlan23)==0, and only tag
42 otherwise.

Sniffing vlan23.42 shows only tag 42 if REORDER_HDR(vlan23.42)==0, no
tag otherwise. REORDER_HDR(vlan23) is ignored, as the packet went up the
stack before.

Sniffing br0 never shows a tag no matter what REORDER_HDR(vlan23) or
REORDER_HDR(vlan23.42) are set to.

> I am starting to lean toward completely ignoring REORDER_HDR on such
> stacked configurations.

Having found the above URLs I am pretty convinced that REORDER_HDR was
introduced to allow enabling it, not the other way around. And given
that the former workaround now has become the default, the former
standard case (i.e. REORDER_HDR==0) can be dropped without sacrifice.

Thanks, Phil
