From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2] openvswitch: Add Kconfig dependency on GRE-DEMUX.
Date: Fri, 28 Jun 2013 14:45:33 -0700
Message-ID: <CALnjE+rNmqFnrUsTDk1LOf18ioGj4EAEZds5E8rjRsqGouiyVQ@mail.gmail.com>
References: <1372448395-30095-1-git-send-email-pshelar@nicira.com>
	<51CDF979.7040605@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	bhutchings@solarflare.com, Jesse Gross <jesse@nicira.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:43522 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752729Ab3F1Vpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 17:45:34 -0400
Received: by mail-qa0-f50.google.com with SMTP id l18so902121qak.2
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 14:45:33 -0700 (PDT)
In-Reply-To: <51CDF979.7040605@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 2:00 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 06/28/13 12:39, Pravin B Shelar wrote:
>> Openvswitch uses function from NET_IPGRE_DEMUX module.
>> Add Kconfig dependency to fix following compilation errors:
>> http://marc.info/?l=linux-netdev&m=137244035226634
>>
>> CC: Jesse Gross <jesse@nicira.com>
>> Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> Signed-off-by: Pravin Shelar <pshelar@nicira.com>
>
> Well, that works if CONFIG_INET is enabled, but if I disable that
> kconfig symbol and then rebuild, this is what happens:
>
>
> net/openvswitch/vport-gre.c: In function 'gre_tnl_send':
> net/openvswitch/vport-gre.c:179:2: error: implicit declaration of function 'iptunnel_xmit' [-Werror=implicit-function-declaration]
>
>
It looks like config bug, I am getting config warning msg with config
you mentioned.
scripts/kconfig/conf --silentoldconfig Kconfig
warning: (OPENVSWITCH) selects NET_IPGRE_DEMUX which has unmet direct
dependencies (NET && INET)
warning: (OPENVSWITCH) selects NET_IPGRE_DEMUX which has unmet direct
dependencies (NET && INET)

----
anyways after discussing it with Jesse, I am going to add config
option for OVS-GRE which depends on INET and NET_IPGRE_DEMUX.

Thanks.

>> ---
>> v1-v2:
>> - use select to resolve dependency.
>> ---
>>  net/openvswitch/Kconfig     |    1 +
>>  net/openvswitch/vport-gre.c |    2 --
>>  net/openvswitch/vport.c     |    3 ---
>>  3 files changed, 1 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
>> index 9fbc04a..deaa9bb 100644
>> --- a/net/openvswitch/Kconfig
>> +++ b/net/openvswitch/Kconfig
>> @@ -4,6 +4,7 @@
>>
>>  config OPENVSWITCH
>>       tristate "Open vSwitch"
>> +     select NET_IPGRE_DEMUX
>>       ---help---
>>         Open vSwitch is a multilayer Ethernet switch targeted at virtualized
>>         environments.  In addition to supporting a variety of features
>> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
>> index 943e5c4..21d5073 100644
>> --- a/net/openvswitch/vport-gre.c
>> +++ b/net/openvswitch/vport-gre.c
>> @@ -16,7 +16,6 @@
>>   * 02110-1301, USA
>>   */
>>
>> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
>>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>>
>>  #include <linux/if.h>
>> @@ -271,4 +270,3 @@ const struct vport_ops ovs_gre_vport_ops = {
>>       .get_name       = gre_get_name,
>>       .send           = gre_tnl_send,
>>  };
>> -#endif
>> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
>> index ba81294..ba240a8 100644
>> --- a/net/openvswitch/vport.c
>> +++ b/net/openvswitch/vport.c
>> @@ -38,10 +38,7 @@
>>  static const struct vport_ops *vport_ops_list[] = {
>>       &ovs_netdev_vport_ops,
>>       &ovs_internal_vport_ops,
>> -
>> -#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
>>       &ovs_gre_vport_ops,
>> -#endif
>>  };
>>
>>  /* Protected by RCU read lock for reading, ovs_mutex for writing. */
>>
>
>
> --
> ~Randy
