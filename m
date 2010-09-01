From: rdunlap@xenotime.net
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Wed, 1 Sep 2010 15:04:24 -0700 (PDT)
Message-ID: <41621.148.87.67.139.1283378664.squirrel@www.xenotime.net>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org, andi@firstfloor.org,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com
To: "Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100901213318.19353.54619.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, September 1, 2010 2:33 pm, Peter P Waskiewicz Jr wrote:
> Documentation/x86/x86_64/boot-options.txt |    4 ++++
> arch/x86/mm/srat_64.c                     |   20 +++++++++++++++++--- 2
> files changed, 21 insertions(+), 3 deletions(-)
>
> diff --git a/arch/x86/mm/srat_64.c b/arch/x86/mm/srat_64.c index
> f9897f7..8719472 100644 --- a/arch/x86/mm/srat_64.c
> +++ b/arch/x86/mm/srat_64.c
> @@ -351,6 +351,15 @@ int __init acpi_get_nodes(struct bootnode *physnodes)
>  return ret; }
>
>
> +int srat_bypass_bios = 0;

static int srat_bypass_bios;

Don't need to init to 0.

> +
> +static int __init srat_bypass_bios_setup(char *str)
> +{
> +        srat_bypass_bios = 1;
> +        return 0;
> +}
> +early_param("sratbypassbios", srat_bypass_bios_setup);
> +
> /* Use the information discovered above to actually set up the nodes. */
> int __init acpi_scan_nodes(unsigned long start, unsigned long end) {
> @@ -425,9 +434,14 @@ int __init acpi_scan_nodes(unsigned long start,
> unsigned long end) nodes[i].end >> PAGE_SHIFT); /* for out of order entries
> in SRAT */ sort_node_map(); -	if (!nodes_cover_memory(nodes)) {
> -		bad_srat();
> -		return -1;
> +	if (!srat_bypass_bios) {
> +		if (!nodes_cover_memory(nodes)) {
> +			bad_srat();
> +			return -1;
> +		}
> +	} else {
> +		printk(KERN_INFO
> +		           "SRAT: Bypassing NUMA sanity check...bad BIOS...\n");
> }
