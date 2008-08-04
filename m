From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Mon, 4 Aug 2008 23:16:07 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl>
References: <20080803143730.7747e9a8@infradead.org>
 <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
 <20080804200058.GX28946@ZenIV.linux.org.uk> <20080804203021.GY28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-2105134054-1217884567=:29400"
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:39179 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758855AbYHDVQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 17:16:16 -0400
In-Reply-To: <20080804203021.GY28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-2105134054-1217884567=:29400
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 4 Aug 2008, Al Viro wrote:

> On Mon, Aug 04, 2008 at 09:00:58PM +0100, Al Viro wrote:
>> On Mon, Aug 04, 2008 at 09:41:10PM +0200, Krzysztof Oledzki wrote:
>>
>>>> BTW: It also happens when I revert my patch:
>>>>
>>>> sysctl -a|grep net.netfilter
>>>>
>>>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>>>> net.netfilter.nf_conntrack_generic_timeout =3D 600
>>>
>>> And the winner is... 9043476f726802f4b00c96d0c4f418dde48d1304:
>>>
>>> [PATCH] sanitize proc_sysctl
>>
>> Almost definitely problems with registration order ;-/  I'll look into
>> that once I get a bit of sleep...
>
> ... and registration order it is.  Try adding
> =09static struct ctl_table empty[1];
> =09register_sysctl_paths(nf_net_netfilter_sysctl_path, empty);
> in netfilter_init() and see if that solves the problem.

Solves partially: no more WARNING, however entries are still=20
missing & duplicated:

# sysctl -a 2>/dev/null|grep net.netfilter
net.netfilter.nf_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_acct =3D 1
net.netfilter.nf_conntrack_generic_timeout =3D 600
net.netfilter.nf_conntrack_acct =3D 1

Plus, without nf_conntrack module loaded I get empty=20
/proc/sys/net/netfilter/, but this is probably expected.

--- a/net/netfilter/core.c     2008-07-13 23:51:29.000000000 +0200
+++ b/net/netfilter/core.c     2008-08-04 22:56:42.000000000 +0200
@@ -26,6 +26,10 @@

  static DEFINE_MUTEX(afinfo_mutex);

+#ifdef CONFIG_SYSCTL
+       static struct ctl_table empty[1];
+#endif
+
  const struct nf_afinfo *nf_afinfo[NPROTO] __read_mostly;
  EXPORT_SYMBOL(nf_afinfo);

@@ -275,6 +279,10 @@
                 panic("cannot create netfilter proc entry");
  #endif

+#ifdef CONFIG_SYSCTL
+       register_sysctl_paths(nf_net_netfilter_sysctl_path, empty);
+#endif
+
         if (netfilter_queue_init() < 0)
                 panic("cannot initialize nf_queue");
         if (netfilter_log_init() < 0)


Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-2105134054-1217884567=:29400--
