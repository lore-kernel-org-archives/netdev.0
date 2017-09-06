From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Wed, 6 Sep 2017 09:54:08 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5ECB@ESESSMB107.ericsson.se>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
	<20170905021112.GA86057@cran64.bj.intel.com>
	<87vakxsaj2.fsf@stressinduktion.org>
	<20170905113848.GC92895@cran64.bj.intel.com>
	<878thtmgra.fsf@stressinduktion.org>
	<20170906005359.GA103260@cran64.bj.intel.com>
	<87o9qo9ru6.fsf@stressinduktion.org>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5D2E@ESESSMB107.ericsson.se>
	<87bmmo9ngt.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <87bmmo9ngt.fsf-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

> > There is no way we can re-use the existing TLV tunnel metadata
> > infrastructure in OVS for matching and setting NSH MD2 TLV headers. We
> > will need to introduce a new (perhaps similar) scheme for modelling
> > generic TLV match registers in OVS that are assigned to protocol TLVs
> > by the controller. This is FFS.
> 
> This is what I don't understand.
> 
> Why can't you just reuse the space in the struct sw_flow_key where
> geneve would put in their metadata. There are 255 empty bytes at the
> beginning if you don't have other tunnel metadata anyway.
> 
> If you receive packets over vxlan(gpe), tun_opts gets populated with an
> ip_tunnel_key. Couldn't you use the options space in there after the
> ip_tunnel_key to store the NSH context just for the sake of storing them
> somewhere instead of adding 16 bytes to sw_flow_key?

There is a significant conceptual difference between tunnel metadata (copied from a popped tunnel header) and packed match fields extracted during parsing of the packets. If we'd store them in the same space in the sw_flow_key struct, we are calling for trouble.

NSH is transport agnostic, it should work over Ethernet, VXLAN(GPE) and other transport tunnels. Think about an NSH packet arriving on an Geneve tunnel port. Any Geneve tunnel options have already been stored in the tun_opts metadata bytes. Now the datapath parses the NSH header and overwrites the tun_opts metadata with the NSH metadata. This would break the OVS semantics.

I absolutely understand your concern about efficient space utilization in the flow struct for TLV match fields and it will be part of the design challenge for MD2 TLV support to find a good balance between memory and run-time efficiency. But that is FFS. For the four fixed size MD1 headers the decision has been to include them as additional attributes in the flow key.

BR, Jan
