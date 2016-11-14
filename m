From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] ip6_output: ensure flow saddr actually
	belongs to device
Date: Mon, 14 Nov 2016 19:33:05 +0100
Message-ID: <1479148385.3747043.787432273.5FCC2F4F@webmail.messagingengine.com>
References: <27cccef1-06d9-74b3-5b8a-912850119a76@cumulusnetworks.com>
 <20161113232813.28926-1-Jason@zx2c4.com>
 <1479141867.3723362.787321689.4A3DCFD6@webmail.messagingengine.com>
 <fd1c804d-3e44-0321-8a3e-67d6ff7357fa@cumulusnetworks.com>
 <7d8c0210-9132-c755-9053-6ec19409e343@stressinduktion.org>
 <c75290bd-7ea2-0bf8-7ac0-fc5a3c81e312@cumulusnetworks.com>
 <7779da88-08dc-0adb-42dd-8e00502693df@stressinduktion.org>
 <0214eaf8-70c6-5a37-cddd-faa1c4268871@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>,
 "Jason A. Donenfeld" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <0214eaf8-70c6-5a37-cddd-faa1c4268871@cumulusnetworks.com>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2016, at 18:48, David Ahern wrote:
> On 11/14/16 10:33 AM, Hannes Frederic Sowa wrote:
> >>>>> I just also quickly read up on the history (sorry was travelling last
> >>>>> week) and wonder if you ever saw a user space facing bug or if this is
> >>>>> basically some difference you saw while writing out of tree code?
> >>>>
> >>>> I checked the userspace API this morning. bind and cmsg for example check that the address is valid with calls to ipv6_chk_addr.
> >>>
> >>> Hmm, so it fixes no real bug.
> >>>
> >>> Because of translations of flowi6_oif we actually can't do a correct
> >>> check of source address for cases like the one I outlined above? Hmm,
> >>> maybe we should simply depend on user space checks.
> >>
> >> I believe Jason's case is forwarding path and the ipv6_stub->ipv6_dst_lookup API.
> > 
> > It is not a kernel API, because we don't support something like that for
> > external kernel modules. We basically exported ipv6_dst_lookup to allow
> > some IPv4 code to do ipv6 stunts when the IPv6 module is loaded. ;)
> 
> ???
> 
> ipv6_stub is exported for modules (EXPORT_SYMBOL_GPL(ipv6_stub)).
> 
> ipv6_stub->ipv6_dst_lookup is used by several modules -- geneve, tipc,
> vxlan, mpls -- for IPv6 lookups, not IPv4 code do IPv6 stunts.
> 
> So how do you say that is not an exported kernel API?

Sorry, yes, I noticed I wrote it in a confusing way.

I meant to say, we don't require the IPv6 "API" to behave in a similar
way like the IPv4 one. We do this function pointer trick to allow
_in-kernel_ tree modules to use the function dynamically, even the
kernel ipv6 module would be available but is not loaded but don't
guarante any "API like IPv4" to outside tree modules.

I tried to make the point, that it is still something internal to the
kernel if compared to out-of-tree function users. And that different
behavior by itself doesn't count as a bug.

We could as well require the users of this function to check for the
source address before or require to check the source address after the
ipv6_dst_lookup call.

vxlan currently seems wrong and would impacted by this patch in a better
way, so I am all in for such a change, but I think we need to check if
we are also correct scope-wise and not just match for the address on its
own.

Thanks,
Hannes
