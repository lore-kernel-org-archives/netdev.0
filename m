From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to
 opt out from becoming the root bridge
Date: Fri, 21 Feb 2014 17:38:48 -0800
Message-ID: <CAB=NE6XtiAG0Q_kEUcomwSss2ftXeiL7Y80MLB55rEtEMGnadg@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
	<20140216105754.63738163@nehalam.linuxnetplumber.net>
	<CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com>
	<1392803559.23084.99.camel@kazak.uk.xensource.com>
	<5304C13F.3030802@citrix.com>
	<CAB=NE6X6Vuo3iib0W-c5cxv0QBpnZtCC0sFyuULugQoEZAbRtg@mail.gmail.com>
	<20140219090855.610c0e04@nehalam.linuxnetplumber.net>
	<CAB=NE6UAqoiFAJdckE1d7cgMZnU6_=8X+N=tSc6qH2bgH08M7Q@mail.gmail.com>
	<20140220091958.62a8b444@nehalam.linuxnetplumber.net>
	<CAB=NE6WnMFkH7JPNt+ROiWEvhvZ03vdGr21STf75DV9fRaK=PA@mail.gmail.com>
	<53074E6B.6030006@citrix.com>
	<CAB=NE6XR+FW2X2_nr2JAxgQD+zpm8=Xq7Y4fTf740rLhGCOzEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@suse.com>, bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAB=NE6XR+FW2X2_nr2JAxgQD+zpm8=Xq7Y4fTf740rLhGCOzEw@mail.gmail.com>
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

On Fri, Feb 21, 2014 at 8:01 AM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> On Fri, Feb 21, 2014 at 5:02 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
>>> Agreed that's the best strategy and I'll work on sending patches to
>>> brctl to enable the root_block preference. This approach however also
>>
>> I don't think brctl should deal with any Xen specific stuff. I assume there
>> is a misunderstanding in this thread: when I (and possibly other Xen folks)
>> talk about "userspace" or "toolstack" here, I mean Xen specific tools which
>> use e.g. brctl to set up bridges. Not brctl itself.
>
> I did mean brctl, but as I looked at the code it doesn't used
> rtnl_open() and not sure if Stephen would want that.

Actually that'd be the incorrect tool to extend, iproute2 would be the
new way with:

ip link add dev xenbr0 type bridge
ip link set dev eth0 master xenbr0
ip link set dev vif1.0 master xenbr0 <root_block>

where root_block would be the new desired argument. This would use the
rtnetlink RTM_SETLINK + IFLA_MASTER, which will in turn kick off the
bridge ndo_add_slave(). Still though it seems this requires the eth0
device to actually exist and as such from what I can tell we can't set
the root_block preference until *after* the addition onto the bridge,
which should mean the bridge could still take the vif1.0 MAC address
momentarily. This is of course only an issue if the link was up during
the additions. This makes me think perhaps nothing is needed then and
scripts could just use the:

bridge link set dev vif1.0 root_block on

I also just noticed that if an entry that was the bridge root port got
a root_block toggle we don't kick off the newly blocked port, I just
verified this. Note that removing the interface from the bridge does
however reset the bridge with a proper new root port:

ip link set dev vif1.0 nomaster

For old userspace with brctl and no iproute2 we're shit out of luck,
this means we can't use root block (xen-netblock was added on
v2.6.39).

Stephen all this can we add the priv_flags flag to help out as
proposed, but I'd make it just toggle the new root_block flag, that'd
enable drivers to use this from initialization. Let me know if you
have other suggestions or things I may have missed.

  Luis
