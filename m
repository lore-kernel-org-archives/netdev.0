From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net] bonding: fix randomly populated arp target array
Date: Fri, 19 May 2017 18:14:05 -0400
Message-ID: <8f60a5ea-7faf-3504-3898-e661a35ebc96@redhat.com>
References: <20170519184646.42572-1-jarod@redhat.com>
 <CAF2d9jiyCcqH=4Ls-GanJmLcMcjJzR=KEkqomFqVonrPv8QAPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        linux-netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?UTF-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAF2d9jiyCcqH=4Ls-GanJmLcMcjJzR=KEkqomFqVonrPv8QAPw@mail.gmail.com>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-05-19 4:38 PM, Mahesh Bandewar (महेश बंडेवार) wrote:
> On Fri, May 19, 2017 at 11:46 AM, Jarod Wilson <jarod@redhat.com> wrote:
>> In commit dc9c4d0fe023, the arp_target array moved from a static global
>> to a local variable. By the nature of static globals, the array used to
>> be initialized to all 0. At present, it's full of random data, which
>> that gets interpreted as arp_target values, when none have actually been
>> specified. Systems end up booting with spew along these lines:
>>
>> [   32.161783] IPv6: ADDRCONF(NETDEV_UP): lacp0: link is not ready
>> [   32.168475] IPv6: ADDRCONF(NETDEV_UP): lacp0: link is not ready
>> [   32.175089] 8021q: adding VLAN 0 to HW filter on device lacp0
>> [   32.193091] IPv6: ADDRCONF(NETDEV_UP): lacp0: link is not ready
>> [   32.204892] lacp0: Setting MII monitoring interval to 100
>> [   32.211071] lacp0: Removing ARP target 216.124.228.17
>> [   32.216824] lacp0: Removing ARP target 218.160.255.255
>> [   32.222646] lacp0: Removing ARP target 185.170.136.184
>> [   32.228496] lacp0: invalid ARP target 255.255.255.255 specified for removal
>> [   32.236294] lacp0: option arp_ip_target: invalid value (-255.255.255.255)
>> [   32.243987] lacp0: Removing ARP target 56.125.228.17
>> [   32.249625] lacp0: Removing ARP target 218.160.255.255
>> [   32.255432] lacp0: Removing ARP target 15.157.233.184
>> [   32.261165] lacp0: invalid ARP target 255.255.255.255 specified for removal
>> [   32.268939] lacp0: option arp_ip_target: invalid value (-255.255.255.255)
>> [   32.276632] lacp0: Removing ARP target 16.0.0.0
>> [   32.281755] lacp0: Removing ARP target 218.160.255.255
>> [   32.287567] lacp0: Removing ARP target 72.125.228.17
>> [   32.293165] lacp0: Removing ARP target 218.160.255.255
>> [   32.298970] lacp0: Removing ARP target 8.125.228.17
>> [   32.304458] lacp0: Removing ARP target 218.160.255.255
>>
>> None of these were actually specified as ARP targets, and the driver does
>> seem to clean up the mess okay, but it's rather noisy and confusing, leaks
>> values to userspace, and the 255.255.255.255 spew shows up even when debug
>> prints are disabled.
>>
>> The fix: just zero out arp_target at init time.
>>
>> While we're in here, init arp_all_targets_value in the right place.
>>
>> Fixes: dc9c4d0fe023 ("bonding: reduce scope of some global variables")
>> CC: Mahesh Bandewar <maheshb@google.com>
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Veaceslav Falico <vfalico@gmail.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> CC: netdev@vger.kernel.org
>> CC: stable@vger.kernel.org
>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>> ---
>>   drivers/net/bonding/bond_main.c | 5 ++---
>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 2be78807fd6e..73313318399c 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -4271,10 +4271,10 @@ static int bond_check_params(struct bond_params *params)
>>          int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
>>          struct bond_opt_value newval;
>>          const struct bond_opt_value *valptr;
>> -       int arp_all_targets_value;
>> +       int arp_all_targets_value = 0;
> 
> I think this is unnecessary as long as the var is initialized before it's use.

No, it's not part of the fix, it just irked me. The extra line is 
completely unnecessary, less lines is good. Possibly shouldn't have 
folded it into this fix, will respin and submit the cleanup another 
time, if necessary.

>>          u16 ad_actor_sys_prio = 0;
>>          u16 ad_user_port_key = 0;
>> -       __be32 arp_target[BOND_MAX_ARP_TARGETS];
>> +       __be32 arp_target[BOND_MAX_ARP_TARGETS] = { 0 };
> 
> this is the only change required to avoid reported error.

Absolutely correct.

-- 
Jarod Wilson
jarod@redhat.com
