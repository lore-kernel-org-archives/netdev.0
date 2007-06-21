From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 6/7] add ioctls for adding/removing target
Date: Thu, 21 Jun 2007 15:39:32 +0530
Message-ID: <a781481a0706210309u5cb05787k83bd0d7cd95e7416@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC76A.6050006@bx.jp.nec.com>
	 <a781481a0706131341k17170514q7a9d0ce052dbfe2a@mail.gmail.com>
	 <4677AA3D.7010604@bx.jp.nec.com>
	 <a781481a0706190809n3387caefv86d289cfd959f805@mail.gmail.com>
	 <467A43B1.3010308@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:33087 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbXFUKJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 06:09:33 -0400
Received: by wr-out-0506.google.com with SMTP id q50so412847wrq
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 03:09:32 -0700 (PDT)
In-Reply-To: <467A43B1.3010308@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Keiichi,

> > Please do consider configfs. Note that we'll have to lose the sysfs
> > symlink from your target's kobject to the kobject of the ethernet
> > device if we switch to configfs, but was that symlink needed for
> > some essential functionality or was it simply for informational
> > purpose? IMHO, this patchset only needs to bring in functionality
> > to be able to create, destroy, and modify netconsole targets at
> > run-time, and all these reconfiguration tasks would be handled
> > quite well by configfs, AFAICT.
>
> It was for informational pupose. But, if we used symlink to the net_device
> kobject in sysfs, we could easily keep up with changing network device name by
> changing symbolic link.

In that case (because it is non-essential) we can drop that link entirely.
(This means the associated code for the temporary modify_list, the
extra mutex and the kasprintf() stuff can also be dropped too!) I guess
the netconsole_event() notifier could now become simply:

	if (event == NETDEV_CHANGENAME) {
		spin_lock_irqsave(&target_list_lock, ...);
		list_for_each_entry(nt, ..., &target_list, ...)
			if (nt->np.dev == dev)
				strcpy(nt->np.dev_name, dev->name);
		spin_unlock_irqrestore(&target_list_lock, ...);
	}

> In the case of configfs, Do we use config_item related to the network interface
> because the configfs doesn't have symlink that refers to net_device kobject
> (e.g. "network_interface" in configfs, "network_interface" value is "eth0")?

Yes, that's a good idea, this way we continue to give the information we
were giving previously. We could do this by defining another configfs
attribute of the target's config_item which could then be a proxy for
the char dev_name[IFNAMSIZ] member of the target's underlying netpoll
structure. (this attribute would naturally be read-only from userspace;
sort of similar to what you're doing for the local_mac attribute currently).

Please feel free to discuss anything else regarding this with me off-list,
if you want.

Thanks,
Satyam
