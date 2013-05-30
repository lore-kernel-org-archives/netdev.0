From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v6 net-next 1/5] net: add napi_id and hash
Date: Thu, 30 May 2013 09:51:13 +0300
Message-ID: <51A6F6E1.3040309@linux.intel.com>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
	<20130529063925.27486.46649.stgit@ladj378.jer.intel.com>
	<1369858192.1971.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1369858192.1971.21.camel@bwh-desktop.uk.level5networks.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 29/05/2013 23:09, Ben Hutchings wrote:
> On Wed, 2013-05-29 at 09:39 +0300, Eliezer Tamir wrote:
>> +void napi_hash_add(struct napi_struct *napi)
>> +{
>> +	if (!test_and_set_bit(NAPI_STATE_HASHED, &napi->state)) {
>> +
>> +		spin_lock(&napi_hash_lock);
>> +
>> +		/* 0 is not a valid id */
>> +		napi->napi_id = 0;
>> +		while (!napi->napi_id)
>> +			napi->napi_id = ++napi_gen_id;
>
> Suppose we're loading/unloading one driver repeatedly while another one
> remains loaded the whole time.  Then once napi_gen_id wraps around, the
> same ID can be assigned to multiple contexts.
>
> So far as I can see, assigning the same ID twice will just make polling
> stop working for one of the NAPI contexts; I don't think it causes a
> crash.  And it is exceedingly unlikely to happen in production.  But if
> you're going to the trouble of handling wrap-around at all, you'd better
> handle this.

OK


> [...]
>> +/* must be called under rcu_read_lock(), as we dont take a reference */
>> +struct napi_struct *napi_by_id(int napi_id)
>> +{
>> +	unsigned int hash = napi_id % HASH_SIZE(napi_hash);
> [...]
>
> napi_id should be declared unsigned int here, as elsewhere.  The
> division can't actually yield a negative result because HASH_SIZE() has
> type size_t and napi_id is promoted to match, but I had to go and look
> at hashtable.h to check that.

Good catch,

Thanks,
Eliezer

------------------------------------------------------------------------------
Introducing AppDynamics Lite, a free troubleshooting tool for Java/.NET
Get 100% visibility into your production application - at no cost.
Code-level diagnostics for performance bottlenecks with <2% overhead
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
