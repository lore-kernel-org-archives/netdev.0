From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 5/6] bonding: Allow userspace to set macaddr on bonding-dev
Date: Sat, 7 Feb 2015 11:15:22 -0800
Message-ID: <CAF2d9jhz=mZ1F-mFCNcJUpS7WJC+Nte=VGrzz-gVBDZkrtOMyA@mail.gmail.com>
References: <1423270316-9311-1-git-send-email-maheshb@google.com>
 <4192.1423272023@famine> <CAF2d9jgV5adAjydN18Ct7BVJJcc=FRc+5icNMS=pRQMRX=83+w@mail.gmail.com>
 <4653.1423274042@famine> <CAF2d9ji=Z+wVz7AdpSeNmOwys0jqWsx6TYsCML_+Hw=u+QMt_A@mail.gmail.com>
 <7179.1423291742@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:36103 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758714AbbBGTPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 14:15:43 -0500
Received: by mail-ob0-f171.google.com with SMTP id gq1so18958168obb.2
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 11:15:43 -0800 (PST)
In-Reply-To: <7179.1423291742@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 10:49 PM, Jay Vosburgh
<jay.vosburgh@canonical.com> wrote:
> Mahesh Bandewar <maheshb@google.com> wrote:
>
>>On Fri, Feb 6, 2015 at 5:54 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>>> Mahesh Bandewar <maheshb@google.com> wrote:
>>>
>>>>On Fri, Feb 6, 2015 at 5:20 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>>>>> Mahesh Bandewar <maheshb@google.com> wrote:
>>>>>
>>>>>>This patch allows user-space to set the mac-address on the bonding device.
>>>>>>This mac-address can not be NULL or a Multicast. If the mac-address is set
>>>>>>from user-space; kernel will honor it and will not overwrite it. In the
>>>>>>absense (value from user space); the logic will default to using the
>>>>>>masters' mac as the mac address for the bonding device.
>>>>>>
>>>>>>It can be set using example code below -
>>>>>>
>>>>>>   # modprobe bonding mode=4
>>>>>>   # sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
>>>>>>                    $(( (RANDOM & 0xFE) | 0x02 )) \
>>>>>>                    $(( RANDOM & 0xFF )) \
>>>>>>                    $(( RANDOM & 0xFF )) \
>>>>>>                    $(( RANDOM & 0xFF )) \
>>>>>>                    $(( RANDOM & 0xFF )) \
>>>>>>                    $(( RANDOM & 0xFF )))
>>>>>>   # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system_mac_address
>>>>>>   # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>>>>>>   ...
>>>>>>   # ip link set bond0 up
>>>>>
>>>>>         How is this patch functionally different from setting the
>>>>> bonding master's MAC address to a particular value prior to adding any
>>>>> slaves?
>>>>>
>>>>
>>>>Maciej is correct but I think I was bit ambiguous about it in the
>>>>commit message which might have made you think this way. I'll reword
>>>>the commit message.
>>>
>>>         Thanks; presumably there is some administrative reason for this.
>>>
>>The idea is that in an AD system the actor-partner communication is a
>>business between them two only and no one in the L2 domain should
>>care. These enhancements should obscure that should anyone try to
>>sniff it. Probably I assumed too much and should add this idea behind
>>the implementation in the commit log.
>
>         Well, the LACPDUs can always be sniffed on ingress to the
> destination linux system with something like tcpdump, but they don't
> propagate, so I'm not sure how a third party would ever see them.  The
> actor_system value isn't really a secret, either, in the sense of
> needing to be kept hidden (your patch even adds it to
> /proc/net/bonding/*).
>
>         Has there been some kind of issue with this?
>
>         In any event, the requirements for the actor_system in the
> standard are pretty much that it's a globally unique MAC address, so
> there's no real issue with permitting it to be set from that
> perspective.
>
As Maciej has explained there is that possibility and with these
enhancements, it not hidden but just obscured so that the device in
the same L2 domain can not pinpoint these DUs to a specific neighbor.

>>>         Also, for patches 4, 5 and 6, I believe current practice is to
>>> provide a netlink / iproute2 facility for options.
>>>
>>OK. I'll add them (netlink enhancements) in a separate set of patch(s).
>
>         Also, I neglected to mention that the new options should be
> added to Documentation/networking/bonding.txt.
>

Yes, I'll update the bonding.txt file in the next patch revision.

>>>>>>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>>>>>>---
>>>>>> drivers/net/bonding/bond_3ad.c     |  7 ++++++-
>>>>>> drivers/net/bonding/bond_main.c    |  1 +
>>>>>> drivers/net/bonding/bond_options.c | 29 +++++++++++++++++++++++++++++
>>>>>> drivers/net/bonding/bond_procfs.c  |  6 ++++++
>>>>>> drivers/net/bonding/bond_sysfs.c   | 16 ++++++++++++++++
>>>>>> include/net/bond_options.h         |  1 +
>>>>>> include/net/bonding.h              |  1 +
>>>>>> 7 files changed, 60 insertions(+), 1 deletion(-)
>>>>>>
>>>>>>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>>>>>>index 1177f96194dd..373d3db3809f 100644
>>>>>>--- a/drivers/net/bonding/bond_3ad.c
>>>>>>+++ b/drivers/net/bonding/bond_3ad.c
>>>>>>@@ -1914,7 +1914,12 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
>>>>>>
>>>>>>               BOND_AD_INFO(bond).system.sys_priority =
>>>>>>                       bond->params.ad_actor_sysprio;
>>>>>>-              BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
>>>>>>+              if (is_zero_ether_addr(bond->params.ad_actor_sys_macaddr))
>>>>>>+                      BOND_AD_INFO(bond).system.sys_mac_addr =
>>>>>>+                          *((struct mac_addr *)bond->dev->dev_addr);
>>>>>>+              else
>>>>>>+                      BOND_AD_INFO(bond).system.sys_mac_addr =
>>>>>>+                          *((struct mac_addr *)bond->params.ad_actor_sys_macaddr);
>>>>>>
>>>>>>               /* initialize how many times this module is called in one
>>>>>>                * second (should be about every 100ms)
>>>>>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>>>>>>index 561b2bde5aeb..1a6735ef2ea7 100644
>>>>>>--- a/drivers/net/bonding/bond_main.c
>>>>>>+++ b/drivers/net/bonding/bond_main.c
>>>>>>@@ -4440,6 +4440,7 @@ static int bond_check_params(struct bond_params *params)
>>>>>>       params->packets_per_slave = packets_per_slave;
>>>>>>       params->tlb_dynamic_lb = 1; /* Default value */
>>>>>>       params->ad_actor_sysprio = ad_actor_sysprio;
>>>>>>+      eth_zero_addr(params->ad_actor_sys_macaddr);
>>>>>>       if (packets_per_slave > 0) {
>>>>>>               params->reciprocal_packets_per_slave =
>>>>>>                       reciprocal_value(packets_per_slave);
>>>>>>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>>>>>>index d8f6760143ae..330d48b6a1e6 100644
>>>>>>--- a/drivers/net/bonding/bond_options.c
>>>>>>+++ b/drivers/net/bonding/bond_options.c
>>>>>>@@ -72,6 +72,8 @@ static int bond_option_tlb_dynamic_lb_set(struct bonding *bond,
>>>>>>                                 const struct bond_opt_value *newval);
>>>>>> static int bond_option_ad_actor_sysprio_set(struct bonding *bond,
>>>>>>                                 const struct bond_opt_value *newval);
>>>>>>+static int bond_option_ad_actor_sys_macaddr_set(struct bonding *bond,
>>>>>>+                                const struct bond_opt_value *newval);
>>>>>>
>>>>>>
>>>>>> static const struct bond_opt_value bond_mode_tbl[] = {
>>>>>>@@ -396,6 +398,13 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
>>>>>>               .values = bond_ad_actor_sysprio_tbl,
>>>>>>               .set = bond_option_ad_actor_sysprio_set,
>>>>>>       },
>>>>>>+      [BOND_OPT_AD_ACTOR_SYS_MACADDR] = {
>>>>>>+              .id = BOND_OPT_AD_ACTOR_SYS_MACADDR,
>>>>>>+              .name = "ad_actor_system_mac_address",
>>>>>>+              .unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
>>>>>>+              .flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
>>>>>>+              .set = bond_option_ad_actor_sys_macaddr_set,
>>>>>>+      },
>>>>>> };
>>>>>>
>>>>>> /* Searches for an option by name */
>>>>>>@@ -1376,3 +1385,23 @@ static int bond_option_ad_actor_sysprio_set(struct bonding *bond,
>>>>>>       bond->params.ad_actor_sysprio = newval->value;
>>>>>>       return 0;
>>>>>> }
>>>>>>+
>>>>>>+static int bond_option_ad_actor_sys_macaddr_set(struct bonding *bond,
>>>>>>+                                          const struct bond_opt_value *newval)
>>>>>>+{
>>>>>>+      u8 macaddr[ETH_ALEN];
>>>>>>+      int i;
>>>>>>+
>>>>>>+      i = sscanf(newval->string, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
>>>>>>+                 &macaddr[0], &macaddr[1], &macaddr[2],
>>>>>>+                 &macaddr[3], &macaddr[4], &macaddr[5]);
>>>>>>+
>>>>>>+      if (i != ETH_ALEN || !is_valid_ether_addr(macaddr)) {
>>>>>>+              netdev_err(bond->dev, "Invalid MAC address.\n");
>>>>>>+              return -EINVAL;
>>>>>>+      }
>>>>>>+
>>>>>>+      ether_addr_copy(bond->params.ad_actor_sys_macaddr, macaddr);
>
>         I think this operation should probably fail if the bond has any
> slaves, as the new value will not actually propagate out to what's being
> used in LACPDUs in that case.
>
>         Looking at the other two new option patches, I think this
> comment also applies to them.
>
You can do this only when the the bond is down.

>         -J
>
>>>>>>+      return 0;
>>>>>>+}
>>>>>>diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
>>>>>>index 9e33c48886ef..81452ced852f 100644
>>>>>>--- a/drivers/net/bonding/bond_procfs.c
>>>>>>+++ b/drivers/net/bonding/bond_procfs.c
>>>>>>@@ -136,6 +136,8 @@ static void bond_info_show_master(struct seq_file *seq)
>>>>>>                          optval->string);
>>>>>>               seq_printf(seq, "System priority: %d\n",
>>>>>>                               BOND_AD_INFO(bond).system.sys_priority);
>>>>>>+              seq_printf(seq, "System MAC address: %pM\n",
>>>>>>+                              &BOND_AD_INFO(bond).system.sys_mac_addr);
>>>>>>
>>>>>>               if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>>>>>                       seq_printf(seq, "bond %s has no active aggregator\n",
>>>>>>@@ -198,6 +200,8 @@ static void bond_info_show_slave(struct seq_file *seq,
>>>>>>                       seq_puts(seq, "details actor lacp pdu:\n");
>>>>>>                       seq_printf(seq, "    system priority: %d\n",
>>>>>>                                  port->actor_system_priority);
>>>>>>+                      seq_printf(seq, "    system mac address: %pM\n",
>>>>>>+                                 &port->actor_system);
>>>>>>                       seq_printf(seq, "    port key: %d\n",
>>>>>>                                  port->actor_oper_port_key);
>>>>>>                       seq_printf(seq, "    port priority: %d\n",
>>>>>>@@ -210,6 +214,8 @@ static void bond_info_show_slave(struct seq_file *seq,
>>>>>>                       seq_puts(seq, "details partner lacp pdu:\n");
>>>>>>                       seq_printf(seq, "    system priority: %d\n",
>>>>>>                                  port->partner_oper.system_priority);
>>>>>>+                      seq_printf(seq, "    system mac address: %pM\n",
>>>>>>+                                 &port->partner_oper.system);
>>>>>>                       seq_printf(seq, "    oper key: %d\n",
>>>>>>                                  port->partner_oper.key);
>>>>>>                       seq_printf(seq, "    port priority: %d\n",
>>>>>>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>>>>>>index 4350aa06f867..91713d0b6685 100644
>>>>>>--- a/drivers/net/bonding/bond_sysfs.c
>>>>>>+++ b/drivers/net/bonding/bond_sysfs.c
>>>>>>@@ -706,6 +706,21 @@ static ssize_t bonding_show_ad_actor_sysprio(struct device *d,
>>>>>> static DEVICE_ATTR(ad_actor_system_priority, S_IRUGO | S_IWUSR,
>>>>>>                  bonding_show_ad_actor_sysprio, bonding_sysfs_store_option);
>>>>>>
>>>>>>+static ssize_t bonding_show_ad_actor_sys_macaddr(struct device *d,
>>>>>>+                                               struct device_attribute *attr,
>>>>>>+                                               char *buf)
>>>>>>+{
>>>>>>+      struct bonding *bond = to_bond(d);
>>>>>>+
>>>>>>+      if (BOND_MODE(bond) == BOND_MODE_8023AD)
>>>>>>+              return sprintf(buf, "%pM\n", bond->params.ad_actor_sys_macaddr);
>>>>>>+
>>>>>>+      return 0;
>>>>>>+}
>>>>>>+static DEVICE_ATTR(ad_actor_system_mac_address, S_IRUGO | S_IWUSR,
>>>>>>+                 bonding_show_ad_actor_sys_macaddr,
>>>>>>+                 bonding_sysfs_store_option);
>>>>>>+
>>>>>> static struct attribute *per_bond_attrs[] = {
>>>>>>       &dev_attr_slaves.attr,
>>>>>>       &dev_attr_mode.attr,
>>>>>>@@ -740,6 +755,7 @@ static struct attribute *per_bond_attrs[] = {
>>>>>>       &dev_attr_packets_per_slave.attr,
>>>>>>       &dev_attr_tlb_dynamic_lb.attr,
>>>>>>       &dev_attr_ad_actor_system_priority.attr,
>>>>>>+      &dev_attr_ad_actor_system_mac_address.attr,
>>>>>>       NULL,
>>>>>> };
>>>>>>
>>>>>>diff --git a/include/net/bond_options.h b/include/net/bond_options.h
>>>>>>index c2af1db37354..993ef73cd050 100644
>>>>>>--- a/include/net/bond_options.h
>>>>>>+++ b/include/net/bond_options.h
>>>>>>@@ -64,6 +64,7 @@ enum {
>>>>>>       BOND_OPT_SLAVES,
>>>>>>       BOND_OPT_TLB_DYNAMIC_LB,
>>>>>>       BOND_OPT_AD_ACTOR_SYSPRIO,
>>>>>>+      BOND_OPT_AD_ACTOR_SYS_MACADDR,
>>>>>>       BOND_OPT_LAST
>>>>>> };
>>>>>>
>>>>>>diff --git a/include/net/bonding.h b/include/net/bonding.h
>>>>>>index 7a5c79fcf866..cd2092e6bc71 100644
>>>>>>--- a/include/net/bonding.h
>>>>>>+++ b/include/net/bonding.h
>>>>>>@@ -144,6 +144,7 @@ struct bond_params {
>>>>>>       int tlb_dynamic_lb;
>>>>>>       struct reciprocal_value reciprocal_packets_per_slave;
>>>>>>       u16 ad_actor_sysprio;
>>>>>>+      u8 ad_actor_sys_macaddr[ETH_ALEN];
>>>>>> };
>>>>>>
>>>>>> struct bond_parm_tbl {
>>>>>>--
>>>>>>2.2.0.rc0.207.ga3a616c
>
> ---
>         -Jay Vosburgh, jay.vosburgh@canonical.com
