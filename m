From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv5 net-next] vxlan: virtual extensible lan
Date: Thu, 27 Sep 2012 16:00:54 -0700
Message-ID: <20120927160054.105f4711@nehalam.linuxnetplumber.net>
References: <20120924145031.3b0122e6@nehalam.linuxnetplumber.net>
	<CAEP_g=_PQSx_OVcU47OJFKgO_MpWSKStmGnVB76vSm=Z7r6mvg@mail.gmail.com>
	<20120925150957.78591205@nehalam.linuxnetplumber.net>
	<20120927.184740.975766966558033959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, chrisw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60285 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756148Ab2I0XBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 19:01:31 -0400
In-Reply-To: <20120927.184740.975766966558033959.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Sep 2012 18:47:40 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 25 Sep 2012 15:09:57 -0700
> 
> > +/* Hash Ethernet address */
> > +static u32 eth_hash(const unsigned char *addr)
> > +{
> > +	/* could be optimized for unaligned access */
> > +	u32 a = addr[5] << 8 | addr[4];
> > +	u32 b = addr[3] << 24 | addr[2] << 16 | addr[1] << 8 | addr[0];
> > +
> > +	return jhash_2words(a, b, vxlan_salt);
> > +}
> > +
> > +/* Hash chain to use given mac address */
> > +static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
> > +						const u8 *mac)
> > +{
> > +	return &vxlan->fdb_head[hash_32(eth_hash(mac), FDB_HASH_BITS)];
> > +}
> 
> This hashing is way overkill, and in fact is a mis-use of Jenkins.
> 
> Jenkins can work fine with power-of-two hash sizes, so using hash_32()
> on the Jenkins hash result is nothing short of silly.
> 
> I would go one step further and change this to:
> 
> 	(a ^ b) * vxlan_salt

Ok, but doubt that it makes much difference.

> 
> much like how we hash IP addresses in the ipv4 ARP tables.  That
> function is a universal hash, and therefore provides whatever kind
> of protection you're trying to obtain using the salt.
> 
> But I wonder if this matters at all, the administrator controls
> the contents of this table, rather than external entitites.

The table includes values learned from packets received. Like a bridge,
a malicious attacker who can forge MAC sourc addresses can overload one
chain by swamping the table with bogus values.  Probably needs a table limit.
