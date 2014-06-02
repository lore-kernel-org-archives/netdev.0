From: Michal Privoznik <mprivozn@redhat.com>
Subject: Re: [PATCH] net-sysfs: Report link speed as signed integer
Date: Mon, 02 Jun 2014 16:43:33 +0200
Message-ID: <538C8D95.2060503@redhat.com>
References: <06d53256e3bf2d0deedb16249082200500da3ee6.1401718809.git.mprivozn@redhat.com> <20140602143557.GA2925@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140602143557.GA2925@minipsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02.06.2014 16:35, Jiri Pirko wrote:
> Mon, Jun 02, 2014 at 04:25:15PM CEST, mprivozn@redhat.com wrote:
>> The link speed is available at /sys/class/net/$nic/speed.
>> However, the speed is printed in unsigned integer format. This
>> makes userspace applications read an incorrect value (which
>> moreover changes through several architectures) while in fact
>> '-1' should be reported.
>>
>> Before the change:
>>   # cat /sys/class/net/eth0/speed
>>   4294967295
>>
>> After the change:
>>   # cat /sys/class/net/eth0/speed
>>   -1
>>
>> Signed-off-by: Michal Privoznik <mprivozn@redhat.com>
>> ---
>> net/core/net-sysfs.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>> index 1cac29e..99afdea 100644
>> --- a/net/core/net-sysfs.c
>> +++ b/net/core/net-sysfs.c
>> @@ -173,7 +173,7 @@ static ssize_t speed_show(struct device *dev,
>> 	if (netif_running(netdev)) {
>> 		struct ethtool_cmd cmd;
>> 		if (!__ethtool_get_settings(netdev, &cmd))
>> -			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
>> +			ret = sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
>
> I wonder why this should be signed. What -1 means? What driver reports
> this?

This is e1000e. It seems like a default value. From e1000_get_settings() 
in drivers/net/ethernet/intel/e1000e/ethtool.c:

     speed = -1;
     ecmd->duplex = -1;

     if (netif_running(netdev)) {
         if (netif_carrier_ok(netdev)) {
             speed = adapter->link_speed;
             ecmd->duplex = adapter->link_duplex - 1;
         }
     } else if (!pm_runtime_suspended(netdev->dev.parent)) {
	...
     }

     ethtool_cmd_speed_set(ecmd, speed);

If I unplug the cord, NIC is nor running nor runtime suspended.

Michal
