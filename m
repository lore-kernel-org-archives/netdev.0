From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/3] bridge: offload bridge port attributes to switch
 asic if feature flag set
Date: Thu, 04 Dec 2014 23:02:27 -0800
Message-ID: <54815883.80909@cumulusnetworks.com>
References: <1417746401-8140-3-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37873 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaLEHCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 02:02:34 -0500
In-Reply-To: <CAE4R7bBOCgoH0zL6+82jj2qjcP8n3kSo51x+i5SoqkN8Ff1CBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 10:41 PM, Scott Feldman wrote:
> On Thu, Dec 4, 2014 at 6:26 PM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This allows offloading to switch asic without having the user to set
>> any flag. And this is done in the bridge driver to rollback kernel settings
>> on hw offload failure if required in the future.
>>
>> With this, it also makes sure a notification goes out only after the
>> attributes are set both in the kernel and hw.
> I like this approach as it streamlines the steps for the user in
> setting port flags.  There is one case for FLOODING where you'll have
> to turn off flooding for both, and then turn on flooding in hw.  You
> don't want flooding turned on on kernel and hw.
ok, maybe using the higher bits as in 
https://patchwork.ozlabs.org/patch/413211/

might help with that. Let me think some more.
>
>> ---
>>   net/bridge/br_netlink.c |   27 ++++++++++++++++++++++++++-
>>   1 file changed, 26 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index 9f5eb55..ce173f0 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -407,9 +407,21 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
>>                                  afspec, RTM_SETLINK);
>>          }
>>
>> +       if ((dev->features & NETIF_F_HW_SWITCH_OFFLOAD) &&
>> +                       dev->netdev_ops->ndo_bridge_setlink) {
>> +               int ret = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
> I think you want to up-level this to net/core/rtnetlink.c because
> you're only enabling the feature for one instance of a driver that
> implements ndo_bridge_setlink: the bridge driver.  If another driver
> was MASTER and implemented ndo_bridge_setlink, you'd want same check
> to push setting down to SELF port driver.

yeah, i thought about that. But i moved it here so that rollback would 
be easier.
>
>> +               if (ret && ret != -EOPNOTSUPP) {
>> +                       /* XXX Fix this in the future to rollback
>> +                        * kernel settings and return error
>> +                        */
> The future is now.  Let's fix this now for the rollback case (again up
> in rtnetlink.c).  So then a general question comes to mind: for these
> dual target sets, is it best to try HW first and then SW, or the other
> way around?  Either way, on failure on second you need to rollback
> first.  And, on failure, you need to know rollback value for first, so
> you have to do a getlink on first before attempting set.
yep, exactly, I went through the same thought process yesterday when i 
was trying to implement rollback.
>
>> +                       br_warn(p->br, "error offloading bridge attributes "
>> +                                       "on port %u(%s)\n", (unsigned int) p->port_no,
>> +                                       p->dev->name);
>> +               }
>> +       }
>> +
>>          if (err == 0)
>>                  br_ifinfo_notify(RTM_NEWLINK, p);
>> -
>>   out:
>>          return err;
>>   }
>> @@ -433,6 +445,19 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
>>          err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
>>                          afspec, RTM_DELLINK);
>>
>> +       if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD
>> +                       && dev->netdev_ops->ndo_bridge_setlink) {
>> +               int ret = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
>> +               if (ret && ret != -EOPNOTSUPP) {
>> +                       /* XXX Fix this in the future to rollback
>> +                        * kernel settings and return error
>> +                        */
>> +                       br_warn(p->br, "error offloading bridge attributes "
>> +                                       "on port %u(%s)\n", (unsigned int) p->port_no,
>> +                                       p->dev->name);
>> +               }
>> +       }
>> +
> Same comments as setlink above.
>
>>          return err;
>>   }
>>   static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>> --
>> 1.7.10.4
>>
