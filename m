From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Mon, 6 Feb 2012 23:50:30 +0000
Message-ID: <1328572230.12637.18.camel@deadeye>
References: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
	 <10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
	 <20120203.192933.510206531351047222.davem@davemloft.net>
	 <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"steweg@ynet.sk" <steweg@ynet.sk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-02-06 at 04:41 +0000, Rose, Gregory V wrote:
[...]
> > This is not how we're going to fix this.  I already stated the desired
> > way to fix this, which is to make the existing dump request have a way
> > for the requestor to enable extended parts of the device dump.
> > 
> > This is just like netlink diag socket dumps, where the dump request
> > specifies what the user wants to see.
> > 
> > In this case we'd add a netlink attribute to the dump request which
> > is just a u32 bitmask or similar.
> > 
> > The Intel engineer who added the VF dump support said he would work on
> > this fix so why don't you just wait patiently for him to do the work?
> 
> The patch below is what I've got so far.  Right now the bit mask array
> is global so if you enable display of VF (n) on one interface it will
> enable display of the same VF on other interfaces.  I intend to move
> the bit mask array into the net_device structure so we can set the
> display mask for each interface independently.

I don't think this can work.  Using an application that requests VF
information and uses large buffers (e.g. the updated 'ip') will break
another application that doesn't (e.g. current Network Manager), won't
it?

The filter should be per-request and not persistent (and I think it
could just be a boolean or a limit value rather than a bitmask).

> The command to set the filter mask is "set only", I see no reason to
> add it to the info dump.  If other folks see it differently then I can
> do that too.
> 
> Anyway, it will allow the user to control which VFs are getting
> displayed during the info dump.  They all default to off so initially
> no VF info gets displayed.
> 
> I've also whipped up a patch for the iproute2 ip command.  It'll work
> like this:
> 
> 'ip link set <dev> vf (n) filter [on|off]'

Well there's no need for a persistent filter.  And I think that the
default behaviour of 'ip' should be to show all the VFs, as it does now.

[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -62,6 +62,9 @@ struct rtnl_link {
>  static DEFINE_MUTEX(rtnl_mutex);
>  static u16 min_ifinfo_dump_size;
>  
> +/* VF info display filter - Number of VFs max is 256 */
> +static unsigned long show_vfinfo_filter[256 / sizeof(unsigned long)];
[...]

This array is 8 times too large; use BITS_TO_LONGS.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
