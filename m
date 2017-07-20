From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net-next v2 1/1] geneve: add rtnl changelink support
Date: Thu, 20 Jul 2017 10:42:25 -0700
Message-ID: <988a77cc-6f23-f3f7-dcf7-e7b988b3cab5@oracle.com>
References: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
 <CAOrHB_CNNzUgNN3GPmAtnceUW-orGGMPnUSS86nRSMtVPN4HHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33132 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965278AbdGTRmf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 13:42:35 -0400
In-Reply-To: <CAOrHB_CNNzUgNN3GPmAtnceUW-orGGMPnUSS86nRSMtVPN4HHw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Pravin,

>> +/* Quiesces the geneve device data path for both TX and RX. */
>> +static inline void geneve_quiesce(struct geneve_dev *geneve,
>> +                                 struct geneve_sock **gs4,
>> +                                 struct geneve_sock **gs6)
>> +{
>> +       *gs4 = rtnl_dereference(geneve->sock4);
>> +       rcu_assign_pointer(geneve->sock4, NULL);
>> +
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +       *gs6 = rtnl_dereference(geneve->sock6);
>> +       rcu_assign_pointer(geneve->sock6, NULL);
>> +#else
>> +       *gs6 = NULL;
>> +#endif
>> +       synchronize_net();
>> +}
>> +
>> +/* Resumes the geneve device data path for both TX and RX. */
>> +static inline void geneve_unquiesce(struct geneve_dev *geneve,
>> +                                   struct geneve_sock *gs4,
>> +                                   struct geneve_sock __maybe_unused *gs6)
>> +{
>> +       rcu_assign_pointer(geneve->sock4, gs4);
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +       rcu_assign_pointer(geneve->sock6, gs6);
>> +#endif
>> +       synchronize_net();
>> +}
>> +
>> +static int geneve_changelink(struct net_device *dev, struct nlattr *tb[],
>> +                            struct nlattr *data[],
>> +                            struct netlink_ext_ack *extack)
>> +{
>> +       struct geneve_dev *geneve = netdev_priv(dev);
>> +       struct geneve_sock *gs4, *gs6;
>> +       struct ip_tunnel_info info;
>> +       bool metadata;
>> +       bool use_udp6_rx_checksums;
>> +       int err;
>> +
>> +       /* If the geneve device is configured for metadata (or externally
>> +        * controlled, for example, OVS), then nothing can be changed.
>> +        */
>> +       if (geneve->collect_md)
>> +               return -EOPNOTSUPP;
>> +
>> +       /* Start with the existing info. */
>> +       memcpy(&info, &geneve->info, sizeof(info));
>> +       metadata = geneve->collect_md;
>> +       use_udp6_rx_checksums = geneve->use_udp6_rx_checksums;
>> +       err = geneve_nl2info(dev, tb, data, &info, &metadata,
>> +                            &use_udp6_rx_checksums, true);
>> +       if (err)
>> +               return err;
>> +
>> +       if (!geneve_dst_addr_equal(&geneve->info, &info))
>> +               dst_cache_reset(&info.dst_cache);
>> +
>> +       geneve_quiesce(geneve, &gs4, &gs6);
>> +       geneve->info = info;
>> +       geneve->collect_md = metadata;
>> +       geneve->use_udp6_rx_checksums = use_udp6_rx_checksums;
>> +       geneve_unquiesce(geneve, gs4, gs6);
>> +
> This is nice trick. But it adds check for the socket in datapath. did
> you explore updating entire device state in single atomic transaction?

I did explore, however what I have now seemed like a more concise method to 
perform changelink operation atomically w.r.t the datapath.

That said, there is one thing I could do. Today we already check for the socket 
in datapath like below:

(a) ipv4 datapath today:
========================

   geneve_xmit_skb(...)
   |
   +->geneve_get_v4_rt(....)
      |
      +---> if (!rcu_dereference(geneve->sock4))
                 return ERR_PTR(-EIO);

(b) ipv4 datapath with my current patch:
========================================

   geneve_xmit_skb(...)
   |
   +->if (!rcu_dereference(geneve->sock4))
   |      return -EIO;
   |
   +->geneve_get_v4_rt(....)
      |
      +---> if (!rcu_dereference(geneve->sock4))
                 return ERR_PTR(-EIO);

Perhaps, I could piggyback on the already existing check for NULL socket in 
geneve_get_v4_rt() and avoid the additional check I have added in datapath. (The 
situation is same for IPv6)

regards,
~Girish
