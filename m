From: Eyal perry <eyalpe@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 1/2] ethtool: Support for configurable RSS
 hash function
Date: Wed, 26 Nov 2014 22:29:33 +0200
Message-ID: <5476382D.2020209@dev.mellanox.co.il>
References: <1416493610-8966-1-git-send-email-amirv@mellanox.com>	<1416493610-8966-2-git-send-email-amirv@mellanox.com> <20141122.165407.641057904952001007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, eyalpe@mellanox.com,
	Tom Lendacky <thomas.lendacky@amd.com>, ariel.elior@qlogic.com,
	prashant@broadcom.com, mchan@broadcom.com, hariprasad@chelsio.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux-net-drivers@solarflare.com, sshah@solarflare.com,
	sbhatewara@vmware.com, pv-drivers@vmware.com
To: David Miller <davem@davemloft.net>, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:64953 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaKZU3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:29:40 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so6234753wiw.9
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 12:29:38 -0800 (PST)
In-Reply-To: <20141122.165407.641057904952001007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2014 11:54 PM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu, 20 Nov 2014 16:26:49 +0200
> 
>> +	/* We require at least one supported parameter to be changed and no
>> +	 * change in any of the unsupported parameters
>> +	 */
>> +	if ((!indir && !key) || hfunc != ETH_RSS_HASH_NO_CHANGE)
>> +		return -EOPNOTSUPP;
>> +
> 
> I know it will make more work for you, but all of these driver
> implementations of this hook should:
> 
> 1) Accept hfunc of whatever hash function the chip is using,
>    not just ETH_RSS_HASH_NO_CHANGE.
> 
> 2) Provide an accurate hfunc value in the ->get() call.
Hello David, Ben, et al,
Before submitting V2, I'd like to consult you regarding the
implementation shown above. I thought of skipping the validity check
which I've described above as "We require at least one supported
parameter...", instead, I think it's better to fail the ->set() call
only in case of unsupported action requested, e.g.:
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE &&
+	    hfunc != ETH_RSS_HASH_TOP)
+		return -EOPNOTSUPP;
+	if (indir)
+		/* set indirection table code ... */
+	if (key)
+		/* set hash key code ... */
The drawbacks are the change of previous behavior (only requests for at
least one change were supported), however it seems more reasonable and
makes the code much more readable.
In similar manner, for the ->get() call, remove the validity checks (as
I suggested in V1), and just protect against NULL pointer dereference, e.g:
-	if (!indir && !key)
-		return -EOPNOTSUPP;
+	if (indir)
+		/* fill in the given indirection table array */
+	if (key)
+		/* fill in the given hash key array */
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
Please advise,
Thanks,
Eyal.
