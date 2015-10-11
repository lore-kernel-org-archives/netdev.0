From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: Re: [PATCH net-next 4/5] bridge: vlan: fix possible null
 ptr derefs on port init and deinit
Date: Sun, 11 Oct 2015 14:43:46 +0200
Message-ID: <561A5982.4070008@blackwall.org>
References: <1443637015-4153-1-git-send-email-razor@blackwall.org>
	<1443637015-4153-5-git-send-email-razor@blackwall.org>
	<20151011122118.GB2793@colbert.mtl.com>
	<561A5918.5050404@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, davem@davemloft.net, vyasevich@gmail.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Ido Schimmel <idosch@mellanox.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <561A5918.5050404@cumulusnetworks.com>
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

On 10/11/2015 02:42 PM, Nikolay Aleksandrov wrote:
> On 10/11/2015 02:21 PM, Ido Schimmel wrote:
>> Wed, Sep 30, 2015 at 09:16:54PM IDT, razor@blackwall.org wrote:
>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>
>>> When a new port is being added we need to make vlgrp available after
>>> rhashtable has been initialized and when removing a port we need to
>>> flush the vlans and free the resources after we're sure noone can use
>>> the port, i.e. after it's removed from the port list and synchronize_rcu
>>> is executed.
>>
>> Hi Nikolay,
>>
>> Changing the order of port deinit breaks symmetry with the init
>> sequence. It also introduces a problem for switchdev drivers. Flushing
>> the VLANs clears HW VLAN filters and then, when port is unlinked from
>> bridge and CHANGEUPPER is received, port is configured to direct traffic
>> to CPU (as it's not offloaded anymore). Doing the reverse (like in this
>> patch) renders the port unusable.
>>
>> Regarding the reason for this change, are you afraid that vlgrp will be
>> accessed in bridge's rx handler or xmit function after it's freed? If
>> so, maybe we can access it using RCU primitives? That way, both the rx
>> handler and xmit function (executed under RCU lock) will either have a
>> valid copy or not. Looking at previous iterations of this code, I see
>> that was the case with the 'net_port_vlans' struct.
>>
>> I can start working on a fix if you agree with the proposed solution.
>>
>> Thanks.
>>
> 
> Hi,
> Ah, I didn't know about this, I feared that something might rely on the
> particular order of the operations but didn't have a way to test this one in
> particular. Anyway, your proposed solution sounds good to me.
> 
> Thank you,
>  Nik

One thing to be careful about is the creation/destruction of the rhashtable itself
and the order of operations in regard to vlgrp visibility, so it's not only if
vlgrp is visible or not - it should be visible after rhashtable has been initialized
and should be removed before it's freed, the rest is pretty straight-forward.
