From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 1/3] bridge: preserve random init MAC address
Date: Tue, 22 Apr 2014 12:41:50 -0700
Message-ID: <CAB=NE6WKyQbh9Eih05szW6708fVTNPgTe62SU5tC2dQkqwJApg@mail.gmail.com>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
	<1394680527-28970-2-git-send-email-mcgrof@do-not-panic.com>
	<20140318201056.7b876394@nehalam.linuxnetplumber.net>
	<20140320020540.GF28801@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kvm@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	xen-devel@lists.xenproject.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140320020540.GF28801@wotan.suse.de>
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

On Wed, Mar 19, 2014 at 7:05 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
> On Tue, Mar 18, 2014 at 08:10:56PM -0700, Stephen Hemminger wrote:
>> On Wed, 12 Mar 2014 20:15:25 -0700
>> "Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:
>>
>> > As it is now if you add create a bridge it gets started
>> > with a random MAC address and if you then add a net_device
>> > as a slave but later kick it out you end up with a zero
>> > MAC address. Instead preserve the original random MAC
>> > address and use it.
>>
>> What is supposed to happen is that the recalculate chooses
>> the lowest MAC address of the slaves. If there are no slaves
>> it might as well just calculate a new random value. There is
>> not great merit in preserving the original defunct address.
>>
>> Or something like this
>> --- a/net/bridge/br_stp_if.c  2014-02-12 08:21:56.733857356 -0800
>> +++ b/net/bridge/br_stp_if.c  2014-03-18 20:09:09.334388826 -0700
>> @@ -235,6 +235,9 @@ bool br_stp_recalculate_bridge_id(struct
>>                       addr = p->dev->dev_addr;
>>
>>       }
>> +
>> +     if (addr == br_mac_zero)
>> +             return false;  /* keep original address */
>>
>>       if (ether_addr_equal(br->bridge_id.addr, addr))
>>               return false;   /* no change */
>>
>> that just keeps the old value.
>
> The old value could be a port which got root blocked, I think
> it can be confusing to see that happen. Either way feel free to
> make the call, I'll provide more details below on perhaps one reason
> to keep the original MAC address.

Stephen, I'd like to respin this series to address all pending
feedback, I'd still like your feedback / call / judgement on this
part. I'm fine either way, just wanted to ensure I highlight the
reasoning of why I kept the original random MAC address. Please keep
in mind that at this point I'm convinced bridging is the *wrong*
solution to networking with guests but it is being used in a lot of
current topologies, this would just help with smoothing out corner
cases.

>> The bridge is in a meaningless state when there are no ports,
>
> Some virtualization topologies may want a backend with no link (or
> perhaps one which is dynamic, with the option to have none) to the
> internet but just a bridge so guests sharing the bridge can talk to
> each other. In this case bridging can be used only to link the
> batch of guests.
>
> In this case the bridge simply acts as a switch, but also can be used as the
> interface for DHCP, for example. In such a case the guests will be doing
> ARP to get to the DHCP server. There's a flurry of ways one can try to get
> all this meshed together including enablign an ARP proxy but I'm looking
> at ways to optimize this further -- but I'd like to address the current
> usage cases first.
>
>> and when the first port is added back it will be used as the
>> new bridge id.
>
> Sure. Let me know how you think we should proceed with this patch based
> on the above.

Thanks in advance.

  Luis
