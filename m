From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Thu, 4 May 2017 16:15:59 +1000
Message-ID: <20170504061559.GA2162@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503221944.1dd0d576@xeon-e3>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:58402 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751195AbdEDGRF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 02:17:05 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v446DnvU052326
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 02:17:04 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7j16wn96-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 02:17:04 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 16:17:01 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v446GoCh48955474
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 16:16:58 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v446GO0Z008763
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 16:16:26 +1000
Content-Disposition: inline
In-Reply-To: <20170503221944.1dd0d576@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 10:19:44PM -0700, Stephen Hemminger wrote:
>On Wed,  3 May 2017 14:44:35 +1000
>Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>
>> +static int ethtool_get_ncsi_channels(struct net_device *dev,
>> +				     void __user *useraddr)
>
>Please don't use an opaque type for this. See how other ethtool
>operations take a struct.
>

After checking output from below command, all other ethtool operations
uses "void __user *" or "char __user *".

   git grep static.*useraddr net/core/ethtool.c

>> +{
>> +	struct ethtool_ncsi_channels *enc;
>> +	short nr_channels;
>Should be __u16 or unsigned not short.
>

Nope, It's for signed number. User expects to get number of available
channels when negative number is passed in. When it's positive, it's
going to get the channels' information.

>> +	ssize_t size = 0;
>> +	int ret;
>> +
>> +	if (!dev->ethtool_ops->get_ncsi_channels)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (copy_from_user(&nr_channels, useraddr + sizeof(enc->cmd),
>> +			   sizeof(nr_channels)))
>> +		return -EFAULT;
>> +
>> +	size = sizeof(*enc);
>> +	if (nr_channels > 0)
>> +		size += nr_channels * sizeof(enc->id[0]);
>
>You have no upper bound on number of channels, and therefore an incorrectly
>application could grab an excessive amount of kernel memory.
>

Yeah, I'll limit it to 256 in next respin. 256 is the maximal number
of channels for one particular net device.

Cheers,
Gavin
