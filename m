From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: Re: [PATCH v3 1/4] geneve: Add geneve udp port offload for ethernet
 devices
Date: Mon, 14 Dec 2015 08:03:31 -0800
Message-ID: <566EE853.5040002@intel.com>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
 <1449598334-97674-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S36TL4YUXxHCUTnw55EPTnD7vRVBdzGFKLUES3+ZSG+m4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	jeffrey.t.kirsher@intel.org, Kiran Patil <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47242 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbbLNQEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 11:04:45 -0500
In-Reply-To: <CALx6S36TL4YUXxHCUTnw55EPTnD7vRVBdzGFKLUES3+ZSG+m4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/11/2015 7:11 PM, Tom Herbert wrote:
> On Tue, Dec 8, 2015 at 10:12 AM, Anjali Singhai Jain
> <anjali.singhai@intel.com> wrote:
>> Add ndo_ops to add/del UDP ports to a device that supports geneve
>> offload.
>>
>> v3: Add some more comments about the use of the new ndo ops.
>>
>> Signed-off-by: Anjali Singhai Jain <anjali.singhai at intel.com>
>> Signed-off-by: Kiran Patil <kiran.patil at intel.com>
>> ---
>>   drivers/net/geneve.c      | 23 +++++++++++++++++++++++
>>   include/linux/netdevice.h | 21 ++++++++++++++++++++-
>>   2 files changed, 43 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
>> index de5c30c..b43fd56 100644
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -371,8 +371,11 @@ static struct socket *geneve_create_sock(struct net *net, bool ipv6,
>>
>>   static void geneve_notify_add_rx_port(struct geneve_sock *gs)
>>   {
>> +       struct net_device *dev;
>>          struct sock *sk = gs->sock->sk;
>> +       struct net *net = sock_net(sk);
>>          sa_family_t sa_family = sk->sk_family;
>> +       __be16 port = inet_sk(sk)->inet_sport;
>>          int err;
>>
>>          if (sa_family == AF_INET) {
>> @@ -381,6 +384,14 @@ static void geneve_notify_add_rx_port(struct geneve_sock *gs)
>>                          pr_warn("geneve: udp_add_offload failed with status %d\n",
>>                                  err);
>>          }
>> +
>> +       rcu_read_lock();
>> +       for_each_netdev_rcu(net, dev) {
>> +               if (dev->netdev_ops->ndo_add_geneve_port)
>> +                       dev->netdev_ops->ndo_add_geneve_port(dev, sa_family,
>> +                                                            port);
>> +       }
>> +       rcu_read_unlock();
> What about IPv6 case?

The driver still gets add port calls for IPv6 and can decide to offload 
L4 RX checksum if the HW is capable.
