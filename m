From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: vlan: add per-vlan struct and
 move to rhashtables
Date: Fri, 25 Sep 2015 20:49:39 +0200
Message-ID: <56059743.8000404@cumulusnetworks.com>
References: <1443200411-7399-1-git-send-email-razor@blackwall.org>
	<20150925113042.51616552@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, vyasevich@gmail.com, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20150925113042.51616552@urahara>
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

On 09/25/2015 08:30 PM, Stephen Hemminger wrote:
> On Fri, 25 Sep 2015 19:00:11 +0200
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> This patch changes the bridge vlan implementation to use rhashtables
>> instead of bitmaps. The main motivation behind this change is that we
>> need extensible per-vlan structures (both per-port and global) so more
>> advanced features can be introduced and the vlan support can be
>> extended. I've tried to break this up but the moment net_port_vlans is
>> changed and the whole API goes away, thus this is a larger patch.
>> A few short goals of this patch are:
>> - Extensible per-vlan structs stored in rhashtables and a sorted list
>> - Keep user-visible behaviour (compressed vlans etc)
>> - Keep fastpath ingress/egress logic the same (optimizations to come
>>   later)
>>
>> Here's a brief list of some of the new features we'd like to introduce:
>> - per-vlan counters
>> - vlan ingress/egress mapping
>> - per-vlan igmp configuration
>> - vlan priorities
>> - avoid fdb entries replication (e.g. local fdb scaling issues)
>>
>> The structure is kept single for both global and per-port entries so to
>> avoid code duplication where possible and also because we'll soon introduce
>> "port0 / aka bridge as port" which should simplify things further
>> (thanks to Vlad for the suggestion!).
>>
>> Now we have per-vlan global rhashtable (bridge-wide) and per-vlan port
>> rhashtable, if an entry is added to a port it'll get a pointer to its
>> global context so it can be quickly accessed later. There's also a
>> sorted vlan list which is used for stable walks and some user-visible
>> behaviour such as the vlan ranges, also for error paths.
>> VLANs are stored in a "vlan group" which currently contains the
>> rhashtable, sorted vlan list and the number of "real" vlan entries.
>> A good side-effect of this change is that it resembles how hw keeps
>> per-vlan data.
>> One important note after this change is that if a VLAN is being looked up
>> in the bridge's rhashtable for filtering purposes (or to check if it's an
>> existing usable entry, not just a global context) then the new helper
>> br_vlan_should_use() needs to be used if the vlan is found. In case the
>> lookup is done only with a port's vlan group, then this check can be
>> skipped.
>>
>> Things tested so far:
>> - basic vlan ingress/egress
>> - pvids
>> - untagged vlans
>> - undef CONFIG_BRIDGE_VLAN_FILTERING
>> - adding/deleting vlans in different scenarios (with/without global ctx,
>>   while transmitting traffic, in ranges etc)
>> - loading/removing the module while having/adding/deleting vlans
>> - extracting bridge vlan information (user ABI), compressed requests
>> - adding/deleting fdbs on vlans
>> - bridge mac change, promisc mode
>> - default pvid change
>> - kmemleak ON during the whole time
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> I understand the motivation, but this looks like building infrastructure
> for something that is not in upstream kernel yet.
> 
Well, the new features I've listed are not yet in the kernel. :-)
I'd like to think of it as ground work for extensible version of the vlan
code, we can later extend it to any number of new features which is not
possible with the current implementation. Any of the above features would
require some (either global or per-port) per-vlan structure.
This is the first step.

> It also increases the footprint of bridge when vlan filtering is used,
> and maybe even for the default case.
The default case is configurable, we can make it start with 4 elements
as opposed to the current default 64 slots, that's why I chose to use
rhashtable.

Cheers,
 Nik
