From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to
 opt out from becoming the root bridge
Date: Fri, 21 Feb 2014 07:59:20 -0800
Message-ID: <CAB=NE6Xx1f2zYaTP=h-319_T4UtsXVjn0+ZPrSuCqXJ6hk5Jhw@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
	<20140216105754.63738163@nehalam.linuxnetplumber.net>
	<CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com>
	<1392803559.23084.99.camel@kazak.uk.xensource.com>
	<5304C13F.3030802@citrix.com>
	<CAB=NE6X6Vuo3iib0W-c5cxv0QBpnZtCC0sFyuULugQoEZAbRtg@mail.gmail.com>
	<530600C5.3070107@citrix.com>
	<CAB=NE6WKhBJyyUO5o8B53J+F4PqF2PHvvbV3=yS3qs0ZDRKH7Q@mail.gmail.com>
	<53074E69.4060206@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <53074E69.4060206@citrix.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 21, 2014 at 5:02 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> On 20/02/14 20:01, Luis R. Rodriguez wrote:
>>
>> On Thu, Feb 20, 2014 at 5:19 AM, Zoltan Kiss <zoltan.kiss@citrix.com>
>> wrote:
>>>
>>> How about this: netback sets the root_block flag and a random MAC by
>>> default. So the default behaviour won't change, DAD will be happy, and
>>> userspace don't have to do anything unless it's using netback for STP
>>> root
>>> bridge (I don't think there are too many toolstacks doing that), in which
>>> case it has to remove the root_block flag instead of setting a random
>>> MAC.
>>
>>
>> :D that's exactly what I ended up proposing too. I mentioned how
>> xen-netback could do this as well, we'd keep or rename the flag I
>> added, and then the bridge could would look at it and enable the root
>> block if the flag is set. Stephen however does not like having the
>> bridge code look at magic flags for this behavior and would prefer for
>> us to get the tools to ask for the root block. Let's follow more up on
>> that thread
>
> We don't need that new flag, just forget about it.

Unless I'm missing something the root_block flag is a bridge port
primitive. This means we can't set it *until* the interface gets added
to a bridge, and even then, its a knob that would be available only to
the bridge.

> Another problem with the random addresses, pointed out by Ian earlier, that
> when adding/removing interfaces, the bridge does recalculate it's MAC
> address, and choose the lowest one. In the general usecase I think that's
> normal, but in case of Xen networking, we would like to keep the bridge
> using the physical interface's MAC, because the local port of the bridge is
> used for Dom0 network traffic, therefore changing the bridge MAC when a
> netback device has lower MAC breaks that traffic.

This is a good reason then to actually have an interface general
specific knob to annotate to the bridge that we'd prefer to root_block
by default, the alternative as you point out below is to have the xen
/ kvm utils to set the bridge MAC address statically, but that'll
requires a userspace upgrade. I'm looking for a kernel solution that
is backwards compatible with old userspace.

> I think the best is to
> address this from userspace: if it set the MAC of the bridge explicitly,
> dev_set_mac_address() does dev->addr_assign_type = NET_ADDR_SET;, so
> br_stp_recalculate_bridge_id() will exit before changing anything.

That will certainly work for new xen / kvm util userspace.

  Luis
