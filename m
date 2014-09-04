From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 12/12] be2net: query max_tx_qs for BE3 super-nic
 profile from FW
Date: Thu, 4 Sep 2014 21:28:18 +0200
Message-ID: <20140904192818.GC1938@nanopsycho.lan>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
 <1409552664-15990-13-git-send-email-sathya.perla@emulex.com>
 <54047045.4080400@cogentembedded.com>
 <CF9D1877D81D214CB0CA0669EFAE020C56D414CF@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sathya Perla <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:41706 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433AbaIDT2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 15:28:22 -0400
Received: by mail-wi0-f182.google.com with SMTP id z2so1762948wiv.15
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 12:28:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CF9D1877D81D214CB0CA0669EFAE020C56D414CF@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 02, 2014 at 06:08:18AM CEST, Sathya.Perla@Emulex.Com wrote:
>> -----Original Message-----
>> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
>> 
>> Hello.
>> 
>> > In the BE3 super-nic profile, the max_tx_qs value can vary for each
>> function.
>> > So the driver needs to query this value from FW instead of using the
>> > pre-defined constant BE3_MAX_TX_QS.
>> 
>> > Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
>> > Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>> > ---
>> >   drivers/net/ethernet/emulex/benet/be_main.c |   13 +++++++++++--
>> >   1 files changed, 11 insertions(+), 2 deletions(-)
>> 
>> > diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
>> b/drivers/net/ethernet/emulex/benet/be_main.c
>> > index f3235d1..a30156b 100644
>> > --- a/drivers/net/ethernet/emulex/benet/be_main.c
>> > +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> > @@ -3324,10 +3324,19 @@ static void BEx_get_resources(struct
>> be_adapter *adapter,
>> >   	 */
>> >   	if (BE2_chip(adapter) || use_sriov ||  (adapter->port_num > 1) ||
>> >   	    !be_physfn(adapter) || (be_is_mc(adapter) &&
>> > -	    !(adapter->function_caps & BE_FUNCTION_CAPS_RSS)))
>> > +	    !(adapter->function_caps & BE_FUNCTION_CAPS_RSS))) {
>> >   		res->max_tx_qs = 1;
>> > -	else
>> > +	} else if (adapter->function_caps &
>> BE_FUNCTION_CAPS_SUPER_NIC) {
>> > +		struct be_resources super_nic_res = {0};
>> 
>>     Empty line is needed after declaration.
>Ok, will  fix it. Thks.

scripts/checkpatch.pl is your friend :)

>
>> 
>> > +		/* On a SuperNIC profile, the driver needs to use the
>> > +		 * GET_PROFILE_CONFIG cmd to query the per-function TXQ
>> limits
>> > +		 */
>> > +		be_cmd_get_profile_config(adapter, &super_nic_res, 0);
>> > +		/* Some old versions of BE3 FW don't report max_tx_qs
>> value */
>> > +		res->max_tx_qs = super_nic_res.max_tx_qs ? :
>> BE3_MAX_TX_QS;
>> > +	} else {
>> >   		res->max_tx_qs = BE3_MAX_TX_QS;
>> > +	}
>> 
>> WBR, Sergei
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
