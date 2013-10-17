From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 net 2/4] bridge: Apply the PVID to priority-tagged
 frames
Date: Thu, 17 Oct 2013 21:14:02 +0900
Message-ID: <1382012042.3746.67.camel@ubuntu-vm-makita>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1381910836-718-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <20131016085537.1cbe9c37@nehalam.linuxnetplumber.net>
	 <525EBBC9.8050809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:60965 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755186Ab3JQMO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 08:14:28 -0400
In-Reply-To: <525EBBC9.8050809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 12:16 -0400, Vlad Yasevich wrote:
> On 10/16/2013 11:55 AM, Stephen Hemminger wrote:
> > On Wed, 16 Oct 2013 17:07:14 +0900
> > Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> >
> >> IEEE 802.1Q says that when we receive priority-tagged (VID 0) frames
> >> use the PVID for the port as its VID.
> >> (See IEEE 802.1Q-2011 6.9.1 and Table 9-2)
> >>
> >> Apply the PVID to not only untagged frames but also priority-tagged frames.
> >>
> >> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> >> ---
> >>   net/bridge/br_vlan.c | 27 ++++++++++++++++++++-------
> >>   1 file changed, 20 insertions(+), 7 deletions(-)
> >>
> >> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> >> index 21b6d21..5a9c44a 100644
> >> --- a/net/bridge/br_vlan.c
> >> +++ b/net/bridge/br_vlan.c
> >> @@ -189,6 +189,8 @@ out:
> >>   bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
> >>   			struct sk_buff *skb, u16 *vid)
> >>   {
> >> +	int err;
> >> +
> >>   	/* If VLAN filtering is disabled on the bridge, all packets are
> >>   	 * permitted.
> >>   	 */
> >> @@ -201,20 +203,31 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
> >>   	if (!v)
> >>   		return false;
> >>
> >> -	if (br_vlan_get_tag(skb, vid)) {
> >> +	err = br_vlan_get_tag(skb, vid);
> >> +	if (!*vid) {
> >>   		u16 pvid = br_get_pvid(v);
> >
> > Ok, but it looks like br_vlan_get_tag() could be cleaner if it just returned
> > the tag, and there was another br_vlan_tag_present() function.

Thank you for reviewing.
I agree with you.
I had been afraid that if it affects other codes because
br_vlan_get_tag() is used in many places else, but now I have decided
not to hesitate to change its signature and behavior.

> 
> I was just thinking about that as well.  If we make br_vlan_get_tag()
> return either the actual tag (if the packet is tagged), or the pvid
> if (untagged/prio_tagged), then we can skp most of this.

Hmm... maybe I don't fully understand you.

Is what you intend something like
	br_allowed_ingress(...) {
		...
		vid = br_vlan_get_tag(skb, v);
		if (!tagged(skb)) put_tag(skb, vid); /* untagged */
		else if (!get_vid(skb)) update_vid(skb, vid); /* prio_tagged */
		...
	}

	br_vlan_get_tag(skb, v) {
		if (tagged(skb)) {
			vid = get_vid(skb);
			if (!vid) return get_pvid(v); /* prio_tagged */
			return vid;
		}
		return get_pvid(v); /* untagged */
	}

This needs double check for prio_tagged at br_allowed_ingress() and
br_vlan_get_tag().

Or if we modify skb->vlan_tci at br_vlan_get_tag(), isn't it a little
dangerous to other codes that use this function in order to just get
vid?

I am thinking it makes things simple that br_vlan_get_tag() returns 0 if
(untagged/prio_tagged).

	br_allowed_ingress(...) {
		...
		vid = br_vlan_get_tag(skb);
		if (!vid) {
			vid = get_pvid(v);
			if (!tagged(skb)) put_tag(skb, vid);/* untagged */
			else update_vid(skb, vid); /* prio_tagged */
		}
		...
	}

	br_vlan_get_tag(skb) {
		if (tagged(skb)) return get_vid(skb);
		return 0;
	}

Thanks,

Toshiaki Makita

> 
> >
> > Also, does this still work if CONFIG_BRIDGE_VLAN_FILTERING is disabled?
> 
> Yes.  br_allowed_ingress becomes an inline if the config option is disabled.
> 
> -vlad
