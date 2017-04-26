From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] netxen_nic: null-terminate serial number string in
 netxen_check_options()
Date: Wed, 26 Apr 2017 14:38:26 -0400 (EDT)
Message-ID: <20170426.143826.1046934906391756246.davem@davemloft.net>
References: <20170425074229.28267-1-jmarchan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jmarchan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59198 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964813AbdDZSi2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:38:28 -0400
In-Reply-To: <20170425074229.28267-1-jmarchan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerome Marchand" <jmarchan@redhat.com>
Date: Tue, 25 Apr 2017 09:42:29 +0200

> The serial_num string in netxen_check_options() is not always properly
> null-terminated. I couldn't find the documention on the serial number
> format and I suspect a proper integer to string conversion is in
> order, but this patch a least prevents the out-of-bound access.
> 
> It solves the following kasan warning:
 ...
> @@ -842,7 +842,7 @@ netxen_check_options(struct netxen_adapter *adapter)
>  {
>  	u32 fw_major, fw_minor, fw_build, prev_fw_version;
>  	char brd_name[NETXEN_MAX_SHORT_NAME];
> -	char serial_num[32];
> +	char serial_num[33];
>  	int i, offset, val, err;
>  	__le32 *ptr32;
>  	struct pci_dev *pdev = adapter->pdev;

Another problem is that the serial_num array is only 4-byte aligned by
accident.  Steps are necessary to make sure the ptr32 assignments don't
take unaligned traps.

Something like:

	union {
		char buf[33];
		__le32 dummy;
	} serial_num;
