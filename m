From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net] bridge: netlink: register netdevice before
 executing changelink
Date: Fri, 7 Apr 2017 18:43:06 +0300
Message-ID: <c3769204-4803-6c5f-1286-c8f1f5e045be@cumulusnetworks.com>
References: <20170407124915.15508-1-idosch@mellanox.com>
	<20170407101055.745d95d0@plumbers-lap.home.lan>
	<3d567660-7fa5-979e-3097-89427270e554@cumulusnetworks.com>
	<20170407112206.77b515cd@plumbers-lap.home.lan>
	<23249e09-a712-920f-9a9f-850055aaf3af@cumulusnetworks.com>
	<20170407113615.15891fde@plumbers-lap.home.lan>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: cera@cera.cz, mlxsw@mellanox.com, netdev@vger.kernel.org, peter@svinota.eu,
	bridge@lists.linux-foundation.org, idosch@mellanox.com, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170407113615.15891fde@plumbers-lap.home.lan>
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

On 07/04/17 18:36, Stephen Hemminger wrote:
> On Fri, 7 Apr 2017 18:27:37 +0300
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> On 07/04/17 18:22, Stephen Hemminger wrote:
>>> On Fri, 7 Apr 2017 17:19:48 +0300
>>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>>   
>>>> On 07/04/17 17:10, Stephen Hemminger wrote:  
>>>>> On Fri, 7 Apr 2017 15:49:15 +0300
>>>>> <idosch@mellanox.com> wrote:
>>>>>     
>>>>>> From: Ido Schimmel <idosch@mellanox.com>
>>>>>>
>>>>>> Peter reported a kernel oops when executing the following command:
>>>>>>
>>>>>> $ ip link add name test type bridge vlan_default_pvid 1
>>>>>>
>>>>>> [13634.939408] BUG: unable to handle kernel NULL pointer dereference at
>>>>>> 0000000000000190
>>>>>> [13634.939436] IP: __vlan_add+0x73/0x5f0
>>>>>> [...]
>>>>>> [13634.939783] Call Trace:
>>>>>> [13634.939791]  ? pcpu_next_unpop+0x3b/0x50
>>>>>> [13634.939801]  ? pcpu_alloc+0x3d2/0x680
>>>>>> [13634.939810]  ? br_vlan_add+0x135/0x1b0
>>>>>> [13634.939820]  ? __br_vlan_set_default_pvid.part.28+0x204/0x2b0
>>>>>> [13634.939834]  ? br_changelink+0x120/0x4e0
>>>>>> [13634.939844]  ? br_dev_newlink+0x50/0x70
>>>>>> [13634.939854]  ? rtnl_newlink+0x5f5/0x8a0
>>>>>> [13634.939864]  ? rtnl_newlink+0x176/0x8a0
>>>>>> [13634.939874]  ? mem_cgroup_commit_charge+0x7c/0x4e0
>>>>>> [13634.939886]  ? rtnetlink_rcv_msg+0xe1/0x220
>>>>>> [13634.939896]  ? lookup_fast+0x52/0x370
>>>>>> [13634.939905]  ? rtnl_newlink+0x8a0/0x8a0
>>>>>> [13634.939915]  ? netlink_rcv_skb+0xa1/0xc0
>>>>>> [13634.939925]  ? rtnetlink_rcv+0x24/0x30
>>>>>> [13634.939934]  ? netlink_unicast+0x177/0x220
>>>>>> [13634.939944]  ? netlink_sendmsg+0x2fe/0x3b0
>>>>>> [13634.939954]  ? _copy_from_user+0x39/0x40
>>>>>> [13634.939964]  ? sock_sendmsg+0x30/0x40
>>>>>> [13634.940159]  ? ___sys_sendmsg+0x29d/0x2b0
>>>>>> [13634.940326]  ? __alloc_pages_nodemask+0xdf/0x230
>>>>>> [13634.940478]  ? mem_cgroup_commit_charge+0x7c/0x4e0
>>>>>> [13634.940592]  ? mem_cgroup_try_charge+0x76/0x1a0
>>>>>> [13634.940701]  ? __handle_mm_fault+0xdb9/0x10b0
>>>>>> [13634.940809]  ? __sys_sendmsg+0x51/0x90
>>>>>> [13634.940917]  ? entry_SYSCALL_64_fastpath+0x1e/0xad
>>>>>>
>>>>>> The problem is that the bridge's VLAN group is created after setting the
>>>>>> default PVID, when registering the netdevice and executing its
>>>>>> ndo_init().
>>>>>>
>>>>>> Fix this by changing the order of both operations, so that
>>>>>> br_changelink() is only processed after the netdevice is registered,
>>>>>> when the VLAN group is already initialized.
>>>>>>
>>>>>> The changelink() call is done on a best-effort basis since unregistering
>>>>>> the netdevice upon failure won't perform a proper cleanup due to a
>>>>>> missing ndo_uninit(), which I'll try to add for net-next.
>>>>>>
>>>>>> Fixes: b6677449dff6 ("bridge: netlink: call br_changelink() during br_dev_newlink()")
>>>>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>>>>>> Reported-by: Peter V. Saveliev <peter@svinota.eu>
>>>>>> ---
>>>>>> Please consider this for 4.4.y, 4.9.y and 4.10.y as well.    
>>>>>
>>>>> Although this patch fixes the OOPS it breaks all the error handling
>>>>> of br_changelink. If bad attributes are passed to newlink, you leave a
>>>>> broken partially configured bridge device. The code needs to cleanup
>>>>> and return the correct errno.
>>>>>     
>>>>
>>>> The cleanup would require adding ndo_uninit() and a much bigger churn
>>>> which doesn't seem okay for -net, it will be targetted at net-next.
>>>> The bridge can always be reconfigured as all of the options can be set
>>>> during runtime, so anything can be fixed, thus the best-effort changelink.
>>>>
>>>> If it is not desirable for -net then maybe we should just revert the
>>>> patch there altogether and make it again correctly with cleanup and so
>>>> on in net-next.
>>>>
>>>>
>>>>  
>>>
>>> Why not just add pointer validation in the PVID attribute parsing.
>>>   
>>
>> We cannot have the changelink() before the register  for many reasons,
>> first the vlan config will not be applied so all of the vlan options
>> won't get set even though they're passed, then the changelink() can
>> cause more trouble via the STP calls (f.e. br_stp_start) which can use
>> br->dev->ifindex (= 0 at that point), also can use br->dev->name (still
>> haven't passed validation and is uninitialized, i.e.
>> dev_get_valid_name() hasn't been called and we can have format
>> specifiers in it), multicast code also has some codepaths that will
>> cause various timers to get started...
>>
>> Moving changelink() after the register is much safer.
>>
> 
> Then just fix error handling. Why not call unregister?
> 

Right, because there's no ndo_uninit() and this will not cleanup the
bridge properly. That's the plan for net-next, reorg the code and add
ndo_uninit() for that reason.

>From Ido's commit message above:
"The changelink() call is done on a best-effort basis since
unregistering the netdevice upon failure won't perform a proper cleanup
due to a missing ndo_uninit(), which I'll try to add for net-next."
