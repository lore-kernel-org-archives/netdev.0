From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 06 Dec 2012 14:19:02 -0800
Message-ID: <87sj7iesdl.fsf@xmission.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com> <12918.1353190488@obiwan.sandelman.ca>
	<87obivu7n7.fsf@xmission.com>
	<CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Ani Sinha <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34490 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab2LFWTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 17:19:10 -0500
In-Reply-To: <CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com>
	(Ani Sinha's message of "Thu, 6 Dec 2012 13:22:08 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ani Sinha <ani@aristanetworks.com> writes:

> On Sat, Nov 17, 2012 at 3:33 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> the vlan header in packets as we receive them.
>>
>> The code is correct except for the case of packets in vlan 0.  Currently
>> the packet reconstruction is ambiguous.  The most recent kernels have
>> a TP_STATUS_VLAN_VALID flag that can be checked to see if the packet was
>> in vlan 0 or if there was no vlan at all.  libpcap probably should be
>> taught how to handle TP_STATUS_VLAN_VALID so that it can get the vlan 0
>> handling correct.
>>
>
> May be this?

Two things.

- TP_STATUS_VLAN_VALID lives in the tp_status field not the tp_vlan_tci field.
- To work on older kernels with binaries compiled with newer headers you
  first want to test for tp_vlan_tci == 0 and then look at the status field for
  TP_STATUS_VALID.

Which means the tests need to look something like:

- if (aux->tp_vlan_tci == 0)
+#if defined(TP_STATUS_VLAN_VALID)
+ if ((aux->tp_vlan_tci == 0) && !(aux->tp_status & TP_STATUS_VLAN_VALID))
+#else
+ if (aux->tp_vlan_tci == 0) /* this is ambigious but without the
+
TP_STATUS_VLAN_VALID flag, there is
+                                                      nothing that we can do */
+#endif

 #ifdef HAVE_TPACKET2
- if (handle->md.tp_version == TPACKET_V2 && h.h2->tp_vlan_tci &&
+ if (handle->md.tp_version == TPACKET_V2 &&
+#if defined(TP_STATUS_VLAN_VALID)
+     (h.h2->tp_vlan_tci || (h.h2->tp_status & TP_STATUS_VALID)) &&
+#else
+     h.h2->tp_vlan_tci &&
+#endif

Eric
