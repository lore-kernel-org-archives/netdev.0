From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH net] i40e: use valid online CPU on q_vector initialization
Date: Mon, 11 Jul 2016 14:22:44 -0300
Message-ID: <5783D5E4.3090902@linux.vnet.ibm.com>
References: <1467040603-23008-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, anjali.singhai@intel.com,
	mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55558 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751828AbcGKRWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 13:22:52 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6BHMZis041780
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 13:22:51 -0400
Received: from e24smtp02.br.ibm.com (e24smtp02.br.ibm.com [32.104.18.86])
	by mx0a-001b2d01.pphosted.com with ESMTP id 242wbn5ugn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 13:22:51 -0400
Received: from localhost
	by e24smtp02.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Mon, 11 Jul 2016 14:22:48 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 786AC1DC0051
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 13:22:37 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6BHMjtU4956262
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 14:22:45 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6BHMiuZ010800
	for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 14:22:45 -0300
In-Reply-To: <1467040603-23008-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2016 12:16 PM, Guilherme G. Piccoli wrote:
> Currently, the q_vector initialization routine sets the affinity_mask
> of a q_vector based on v_idx value. Meaning a loop iterates on v_idx,
> which is an incremental value, and the cpumask is created based on
> this value.
>
> This is a problem in systems with multiple logical CPUs per core (like in
> SMT scenarios). If we disable some logical CPUs, by turning SMT off for
> example, we will end up with a sparse cpu_online_mask, i.e., only the first
> CPU in a core is online, and incremental filling in q_vector cpumask might
> lead to multiple offline CPUs being assigned to q_vectors.
>
> Example: if we have a system with 8 cores each one containing 8 logical
> CPUs (SMT == 8 in this case), we have 64 CPUs in total. But if SMT is
> disabled, only the 1st CPU in each core remains online, so the
> cpu_online_mask in this case would have only 8 bits set, in a sparse way.
>
> In general case, when SMT is off the cpu_online_mask has only C bits set:
> 0, 1*N, 2*N, ..., C*(N-1)  where
> C == # of cores;
> N == # of logical CPUs per core.
> In our example, only bits 0, 8, 16, 24, 32, 40, 48, 56 would be set.
>
> This patch changes the way q_vector's affinity_mask is created: it iterates
> on v_idx, but consumes the CPU index from the cpu_online_mask instead of
> just using the v_idx incremental value.
>
> No functional changes were introduced.
>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++++++++++-----
>   1 file changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 5ea2200..a89bddd 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -7726,10 +7726,11 @@ static int i40e_init_msix(struct i40e_pf *pf)
>    * i40e_vsi_alloc_q_vector - Allocate memory for a single interrupt vector
>    * @vsi: the VSI being configured
>    * @v_idx: index of the vector in the vsi struct
> + * @cpu: cpu to be used on affinity_mask
>    *
>    * We allocate one q_vector.  If allocation fails we return -ENOMEM.
>    **/
> -static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
> +static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx, int cpu)
>   {
>   	struct i40e_q_vector *q_vector;
>
> @@ -7740,7 +7741,8 @@ static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
>
>   	q_vector->vsi = vsi;
>   	q_vector->v_idx = v_idx;
> -	cpumask_set_cpu(v_idx, &q_vector->affinity_mask);
> +	cpumask_set_cpu(cpu, &q_vector->affinity_mask);
> +
>   	if (vsi->netdev)
>   		netif_napi_add(vsi->netdev, &q_vector->napi,
>   			       i40e_napi_poll, NAPI_POLL_WEIGHT);
> @@ -7764,8 +7766,7 @@ static int i40e_vsi_alloc_q_vector(struct i40e_vsi *vsi, int v_idx)
>   static int i40e_vsi_alloc_q_vectors(struct i40e_vsi *vsi)
>   {
>   	struct i40e_pf *pf = vsi->back;
> -	int v_idx, num_q_vectors;
> -	int err;
> +	int err, v_idx, num_q_vectors, current_cpu;
>
>   	/* if not MSIX, give the one vector only to the LAN VSI */
>   	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
> @@ -7775,10 +7776,15 @@ static int i40e_vsi_alloc_q_vectors(struct i40e_vsi *vsi)
>   	else
>   		return -EINVAL;
>
> +	current_cpu = cpumask_first(cpu_online_mask);
> +
>   	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
> -		err = i40e_vsi_alloc_q_vector(vsi, v_idx);
> +		err = i40e_vsi_alloc_q_vector(vsi, v_idx, current_cpu);
>   		if (err)
>   			goto err_out;
> +		current_cpu = cpumask_next(current_cpu, cpu_online_mask);
> +		if (unlikely(current_cpu >= nr_cpu_ids))
> +			current_cpu = cpumask_first(cpu_online_mask);
>   	}
>
>   	return 0;
>


Ping?

Sorry to bother, if you think I need to improve something here, let me 
know :)

I'm adding another Intel people in this thread, based on patches to i40e.

Thanks in advance,



Guilherme
