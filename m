From: Ben Greear <greearb@candelatech.com>
Subject: Question on ipmr.c locking in 2.6.25
Date: Wed, 28 May 2008 14:38:54 -0700
Message-ID: <483DD0EE.1020700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:54754 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbYE1Vi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 17:38:56 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m4SLcsGU018016
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 28 May 2008 14:38:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like this method can return without unlocking the
mrt_lock or mfc_unres_lock.  Is this a bug, or am I just
confused about how it is supposed to work?

I haven't reproduced any problem..just staring at the code
while trying to add support for multiple routing tables...

static struct mfc_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
{
	struct mfc_cache *mfc;

	it->cache = mfc_cache_array;
	read_lock(&mrt_lock);
	for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
		for (mfc = mfc_cache_array[it->ct]; mfc; mfc = mfc->next)
			if (pos-- == 0)
				return mfc;
	read_unlock(&mrt_lock);

	it->cache = &mfc_unres_queue;
	spin_lock_bh(&mfc_unres_lock);
	for (mfc = mfc_unres_queue; mfc; mfc = mfc->next)
		if (pos-- == 0)
			return mfc;
	spin_unlock_bh(&mfc_unres_lock);

	it->cache = NULL;
	return NULL;
}

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

