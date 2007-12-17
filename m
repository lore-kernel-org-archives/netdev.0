From: "Aggrwal Poonam" <Poonam.Aggrwal@freescale.com>
Subject: RE: [PATCH 2/3] arch/ : Platform changes for UCC TDM driver for MPC8323ERDB.Also includes related QE changes.
Date: Mon, 17 Dec 2007 11:24:40 +0530
Message-ID: <FBA61160C48B8D438F3323FEFB4EF2C2610FFB@zin33exm24.fsl.freescale.net>
References: <Pine.LNX.4.64.0712101734490.29623@linux121> <20071211111855.dc5276a2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <rubini@vision.unipv.it>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "Gala Kumar" <kumar.gala@freescale.com>,
	<linuxppc-dev@ozlabs.org>,
	"Barkowski Michael" <Michael.Barkowski@freescale.com>,
	"Cutler Richard" <Rich.Cutler@freescale.com>,
	"Kalra Ashish" <ashish.kalra@freescale.com>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:62615 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbXLQF6h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 00:58:37 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071211111855.dc5276a2.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Stephen for your comments.
I have gone through them.
Shall incorporate them and repost the patch.

Sorry for late reply as I was on leave for the last week. 


With Regards
Poonam 
 
 

-----Original Message-----
From: Stephen Rothwell [mailto:sfr@canb.auug.org.au] 
Sent: Tuesday, December 11, 2007 5:49 AM
To: Aggrwal Poonam
Cc: rubini@vision.unipv.it; linux-kernel@vger.kernel.org;
netdev@vger.kernel.org; Gala Kumar; linuxppc-dev@ozlabs.org; Barkowski
Michael; Cutler Richard; Kalra Ashish
Subject: Re: [PATCH 2/3] arch/ : Platform changes for UCC TDM driver for
MPC8323ERDB.Also includes related QE changes.

On Mon, 10 Dec 2007 17:39:22 +0530 (IST) Poonam_Aggrwal-b10812
<b10812@freescale.com> wrote:
>
> +++ b/arch/powerpc/sysdev/qe_lib/qe.c
> @@ -149,22 +149,116 @@ EXPORT_SYMBOL(qe_issue_cmd);
>   */
>  static unsigned int brg_clk = 0;
>  
> -unsigned int get_brg_clk(void)
> +u32 get_brg_clk(enum qe_clock brgclk, enum qe_clock *brg_source)
>  {
> -	struct device_node *qe;
> -	if (brg_clk)
> -		return brg_clk;
> +	struct device_node *qe, *brg, *clocks;
> +	enum qe_clock brg_src;
> +	u32 brg_input_freq = 0;
> +	u32 brg_num;
> +	const unsigned int *prop;
>  
> -	qe = of_find_node_by_type(NULL, "qe");
> -	if (qe) {
> +	*brg_source = 0;
> +
> +	brg_num = brgclk - QE_BRG1;
> +	brg = of_find_compatible_node(NULL, NULL, "fsl,cpm-brg");
> +	if (brg) {
>  		unsigned int size;
> -		const u32 *prop = of_get_property(qe, "brg-frequency",
&size);
> -		brg_clk = *prop;
> -		of_node_put(qe);
> -	};
> +		prop = of_get_property(brg,
> +					"fsl,brg-sources", &size);
> +
> +		brg_src = *(prop + brg_num);

You should probably sanity check that prop is not NULL and points to
something large enough.

You don't use brg after here, so the "of_node_put(brg)" could go here to
save putting it in multiple places later.  Also, currently there are
paths through the following code that do not do the of_node_put(brg).

> +		if (brg_src == 0) {
> +			*brg_source = 0;
> +			if (brg_clk > 0) {
> +				of_node_put(brg);
> +				return brg_clk;
> +			}
> +			qe = of_find_node_by_type(NULL, "qe");
> +			if (qe) {
> +				unsigned int size;
> +				prop = of_get_property
> +						(qe, "brg-frequency",
&size);
> +				of_node_put(qe);
> +				of_node_put(brg);
> +				return *prop;

NULL check here (yes, I know that the old code didn't check).

> +			}
> +		} else {
> +			*brg_source = brg_src + QE_CLK1 - 1;
> +			clocks = of_find_compatible_node(NULL, NULL,
> +
"fsl,cpm-clocks");
> +			prop = of_get_property(clocks,
> +						"#clock-cells", &size);
> +			/*
> +			 * clock-cells = 1 only supported right now.
> +			 */
> +			if (*prop != 1)

Again check for NULL (and possibly size).

> +				return 0;
> +			prop = of_get_property(clocks,
> +						"clock-frequency",
&size);
> +
> +			brg_input_freq = *(prop+(brg_src - 1));

And again.

> +			of_node_put(clocks);
> +			of_node_put(brg);
> +			return brg_input_freq;
> +		}
> +	}
>  	return brg_clk;
>  }
--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
