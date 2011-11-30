From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 PATCH 0/6 v4] macvlan: MAC Address filtering
 support for passthru mode
Date: Wed, 30 Nov 2011 13:04:54 -0800
Message-ID: <20111130210454.GC29071@x200.localdomain>
References: <1321575301.2749.51.camel@bwh-desktop>
 <4EC5A785.3060108@intel.com>
 <1321577078.2749.58.camel@bwh-desktop>
 <4EC68EBB.3080303@intel.com>
 <1321638038.2883.28.camel@bwh-desktop>
 <4ECA8D50.9080603@intel.com>
 <1322584544.2684.20.camel@bwh-desktop>
 <1322587170.2684.26.camel@bwh-desktop>
 <4ED6691D.9070606@intel.com>
 <1322678890.2762.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Rose <gregory.v.rose@intel.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1322678890.2762.26.camel@bwh-desktop>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ben Hutchings (bhutchings@solarflare.com) wrote:
> On Wed, 2011-11-30 at 09:34 -0800, Greg Rose wrote:
> > On 11/29/2011 9:19 AM, Ben Hutchings wrote:
> > > On Tue, 2011-11-29 at 16:35 +0000, Ben Hutchings wrote:
> > >>
> > >> Maybe I missed something!
> [...]
> > >> If not, please explain what the new model *is*.
> > 
> > The new model is to incorporate a VEB into the NIC.  The current model 
> > doesn't address any of the requirements of a VEB in the NIC and this 
> > proposed set of patches allow us to set MAC filters for the *ports* on 
> > the internal NIC VEB.  Consider the PF and each of the VFs as just a 
> > port on the VEB.  We need the ability to set L2 filters (MAC, MC and 
> > VLAN) for each of the ports on that VEB.  There is no currently 
> > supported method for doing this.  So yes, this is a new model although 
> > it's a fairly simple one.
> 
> Explain precisely how the VEB changes the existing model.  Explain how
> the existing MAC filter and VF filter APIs interact with port filters on
> the VEB.  Refer to any relevant standards.

I agree that it's confusing.  Couldn't you simplify your ascii art
(hopefully removing hw assumptions about receive processing, and
completely ignoring vlans for the moment) to something like:

             |RX
             v
+------------+-------------+
|     +------+--------+    |
|     | RX MAC filter |    |
|     |and port select|    |
|     +---------------+    |
|            /|\           |
|           / | \   match 2|
|          /  v  \         |
|         /match  \        |
|        /  1 |    \       |
|       /     |     \      |
|match /      |      \     |
|  0  /       |       \    |
|    v        |        v   |
|    |        |        |   |
+----+--------+--------+---+
     |        |        |
    PF       VF 1     VF 2

And there's an unclear number of ways to update "RX MAC filter and port
select" table.

1) PF ndo_set_mac_addr
I expect that to be implicit to match 0.

2) PF ndo_set_rx_mode
Less clear, but I'd still expect these to implicitly match 0

3) PF ndo_set_vf_mac
I expect these to be an explicit match to VF N (given the interface
specifices which VF's MAC is being programmed).

4) VF ndo_set_mac_addr
This one may or may not be allowed (setting MAC+port if the VF is owned
by a guest is likely not allowed), but would expect an implicit VF N.

5) VF ndo_set_rx_mode
Same as 4) above.

6) PF or VF? ndo_set_rx_filter_addr
The new proposal, which has an explicit VF, although when it's VF_SELF
I'm not clear if this is just the same as 5) above?

Have I missed anything?

thanks,
chris
