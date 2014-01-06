From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bridge: use spin_lock_bh() in
 br_multicast_set_hash_max
Date: Mon, 06 Jan 2014 16:41:15 -0500 (EST)
Message-ID: <20140106.164115.2191339437526329685.davem@davemloft.net>
References: <20140106190032.10912.1521.stgit@monster-03.cumulusnetworks.com>
	<CAHA+R7MB4Pf=eF-7=3gGH-j1mmJLtrjxFqv0bBXF1BBd1D=kuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org
To: cwang@twopensource.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHA+R7MB4Pf=eF-7=3gGH-j1mmJLtrjxFqv0bBXF1BBd1D=kuQ@mail.gmail.com>
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

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 6 Jan 2014 11:11:45 -0800

> On Mon, Jan 6, 2014 at 11:00 AM, Scott Feldman
> <sfeldma@cumulusnetworks.com> wrote:
>> From: Curt Brune <curt@cumulusnetworks.com>
>>
>> br_multicast_set_hash_max() is called from process context in
>> net/bridge/br_sysfs_br.c by the sysfs store_hash_max() function.
>>
>> br_multicast_set_hash_max() calls spin_lock(&br->multicast_lock),
>> which can deadlock the CPU if a softirq that also tries to take the
>> same lock interrupts br_multicast_set_hash_max() while the lock is
>> held .  This can happen quite easily when any of the bridge multicast
>> timers expire, which try to take the same lock.
>>
>> The fix here is to use spin_lock_bh(), preventing other softirqs from
>> executing on this CPU.
>>
>> Steps to reproduce:
>>
>> 1. Create a bridge with several interfaces (I used 4).
>> 2. Set the "multicast query interval" to a low number, like 2.
>> 3. Enable the bridge as a multicast querier.
>> 4. Repeatedly set the bridge hash_max parameter via sysfs.
>>
>>   # brctl addbr br0
>>   # brctl addif br0 eth1 eth2 eth3 eth4
>>   # brctl setmcqi br0 2
>>   # brctl setmcquerier br0 1
>>
>>   # while true ; do echo 4096 > /sys/class/net/br0/bridge/hash_max; done
>>
> 
> 
> I think this should probably go to net instead of net-next,
> and -stable too.

Agreed, applied to 'net' and queued up for -stable.
