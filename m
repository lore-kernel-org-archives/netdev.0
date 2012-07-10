From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/2] bonding: debugfs and network namespaces are incompatible
Date: Tue, 10 Jul 2012 12:13:01 -0700
Message-ID: <16903.1341947581@death.nxdomain>
References: <20120706194741.GA22113@mail.hallyn.com> <87y5ms3bfi.fsf_-_@xmission.com> <87sjd03bdw.fsf_-_@xmission.com> <20120709.144932.243254122059983829.davem@davemloft.net> <15459.1341941772@death.nxdomain> <367b470c-c3f5-4555-be11-02223125b741@email.android.com>
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:45605 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423Ab2GJTOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 15:14:49 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 10 Jul 2012 13:14:48 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 11F8919D8070
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 19:14:00 +0000 (WET)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6AJD3En268752
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 13:13:03 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6AJD2EP005651
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 13:13:02 -0600
In-reply-to: <367b470c-c3f5-4555-be11-02223125b741@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	[ adding netdev back to cc: ]

Eric W. Biederman <ebiederm@xmission.com> wrote:

>Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>>David Miller <davem@davemloft.net> wrote:
>>
>>>From: ebiederm@xmission.com (Eric W. Biederman)
>>>Date: Mon, 09 Jul 2012 13:52:43 -0700
>>>
>>>> 
>>>> The bonding debugfs support has been broken in the presence of
>>network
>>>> namespaces since it has been added.  The debugfs support does not
>>handle
>>>> multiple bonding devices with the same name in different network
>>>> namespaces.
>>>> 
>>>> I haven't had any bug reports, and I'm not interested in getting
>>any.
>>>> Disable the debugfs support when network namespaces are enabled.
>>>> 
>>>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>>
>>>Applied.
>>
>>	Since distro kernels appear to set CONFIG_NET_NS, doesn't this
>>effectively disable debugfs for bonding on most distros?
>
>Yes.
>
>>	Do the other network device drivers that support debugfs have a
>>similar problem?  E.g., if each of two namespaces have an skge device
>>with the same name, will there be a debugfs conflict there as well?
>
>I haven't run across any of those network devices, but if they create a
>debugfs entry that embeds the device name it will be a problem.

	A quick grep suggests that cxgb4, skge, sky2, stmmac, ipoib and
half a dozen of the wireless drivers all create files in debugfs.  I did
not check exhaustively, but at least some of them include the device
name.

>Last I looked any custom user space interface from network devices was
>rare and bonding using debugfs is the first instance of using debugfs
>from networking devices I have seen.
>
>I think the problem will be a little less severe for physical network
>devices as they all start in the initial network namespace and so start
>with distinct names.
>
>With bonding I can do "ip link add type bond" in any network namespace
>and get another bond0.  So name conflicts are very much expeted with all
>virtual networking devices.

	Fair enough, although it is trivial to rename any network device
such that a conflict would occur.

	It looks like some of the drivers use fixed names for some
things as well.

>But if you know of any other networking devices using debugsfs that
>code should probably get the same treatment as the bonding debugfs code.

	Is there no alternative than simply disabling debugfs whenever
network namespaces are enabled?  The information bonding displays via
debugfs is useful, and having it unavailable on all distro kernels seems
a bit harsh.

	Why is the logic already in the driver not sufficient?  If the
attempt to create the debugfs directory with the interface name fails,
then it merely prints a warning and continues without the debugfs for
that interface.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
