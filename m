From: Benjamin ZORES <benjamin.zores@alcatel-lucent.fr>
Subject: Re: [PATCH] Fix infinite retry loop in IP-Config
Date: Wed, 28 Jan 2009 13:08:15 +0100
Message-ID: <49804AAF.7020702@alcatel-lucent.fr>
References: <20090128105220.GB4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050602020906070600070602"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smail4.alcatel.fr ([62.23.212.167]:40758 "EHLO
	smail4.alcatel.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZA1MJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 07:09:59 -0500
Received: from bsf.alcatel.fr (mail205.sxb.bsf.alcatel.fr [155.132.205.115])
	by smail4.alcatel.fr (ALCANET/NETFR) with ESMTP id n0SC9uus024080
	for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 13:09:56 +0100
Received: from mail (mail-bsf-alcatel-fr.sxb.bsf.alcatel.fr [155.132.205.91])
	by bsf.alcatel.fr (8.8.8p2+Sun/8.9.3) with ESMTP id NAA06905
	for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 13:09:55 +0100 (MET)
Received: from [172.25.51.190] (frilld0f09516 [172.25.51.190])
	by mail (8.8.8p2+Sun/) with ESMTP id NAA06901
	for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 13:09:55 +0100 (MET)
In-Reply-To: <20090128105220.GB4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050602020906070600070602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Jarek Poplawski a écrit :
> On 28-01-2009 10:07, Benjamin ZORES wrote:
>   
>> Hi,
>>
>> The attached patch fixes some bug with ip-config max retry number.
>> In ip_auto_config(), kernel tries to retrieve IP configuration forever
>> in case of NFS root and some specific amount of time otherwise.
>>
>> The problem is that, in case of error, the code jump to the try_try_again
>> goto statement, that reassigns the retry number counter, which obviously
>> leads to an infinite loop if IP config fails.
>>
>> The attached patch corrects this behavior.
>> Hope one can push it to mainstream kernel tree.
>>
>> Ben
>>
>> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
>> index 42a0f3d..4911b81 100644
>> --- a/net/ipv4/ipconfig.c
>> +++ b/net/ipv4/ipconfig.c
>> @@ -1268,6 +1268,7 @@ __be32 __init root_nfs_parse_addr(char *name)
>>  static int __init ip_auto_config(void)
>>  {
>>  	__be32 addr;
>> +	 int retries = CONF_OPEN_RETRIES;
>>     
>  
> Doesn't it need "#ifdef IPCONFIG_DYNAMIC" to prevent a compiler
> warning? I guess you could add a "Signed-off-by:" line BTW.
>   
You're perfectly right about this.
Attached an updated version of the patch.

Ben

--------------050602020906070600070602
Content-Type: text/x-diff;
 name="netdev-ipconfig-retry-fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netdev-ipconfig-retry-fix.diff"

commit 4f9928e4ed6aae2a4c2f2216cab1c16e38631a88
Author: Benjamin Zores <benjamin.zores@alcatel-lucent.fr>
Signed-off-by: Benjamin Zores <benjamin.zores@alcatel-lucent.fr>
Date:   Wed Jan 28 13:03:07 2009 +0100

    fix infinite retry loop in IP-Config

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 42a0f3d..5fad34d 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1268,6 +1268,9 @@ __be32 __init root_nfs_parse_addr(char *name)
 static int __init ip_auto_config(void)
 {
        __be32 addr;
+#ifdef IPCONFIG_DYNAMIC
+        int retries = CONF_OPEN_RETRIES;
+#endif
 
 #ifdef CONFIG_PROC_FS
        proc_net_fops_create(&init_net, "pnp", S_IRUGO, &pnp_seq_fops);
@@ -1305,8 +1308,6 @@ static int __init ip_auto_config(void)
            ic_first_dev->next) {
 #ifdef IPCONFIG_DYNAMIC
 
-               int retries = CONF_OPEN_RETRIES;
-
                if (ic_dynamic() < 0) {
                        ic_close_devs();
 



--------------050602020906070600070602--
