From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 13/15] ixgbe: clean up
 ixgbe_atr_compute_perfect_hash_82599
Date: Thu, 20 Mar 2014 09:44:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E224D@AcuExch.aculab.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1395304385-6874-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jacob Keller <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Arun Sharma <asharma@fb.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57022 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933594AbaCTJqX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 05:46:23 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03367-02 for <netdev@vger.kernel.org>;
 Thu, 20 Mar 2014 09:46:18 +0000 (GMT)
In-Reply-To: <1395304385-6874-14-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> Rather than assign several parameters in a row, we should use a for
> loop, which reduces code size.

And probably increases execution time.
Especially for the first two blocks.

...
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> index bdac7bd..34ab2fc 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> @@ -1597,35 +1597,20 @@ void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
>  {
> 
>  	u32 hi_hash_dword, lo_hash_dword, flow_vm_vlan;
> -	u32 bucket_hash = 0;
> +	u32 bucket_hash = 0, hi_dword = 0;
> +	int i;
> 
>  	/* Apply masks to input data */
> -	input->dword_stream[0]  &= input_mask->dword_stream[0];
> -	input->dword_stream[1]  &= input_mask->dword_stream[1];
> -	input->dword_stream[2]  &= input_mask->dword_stream[2];
> -	input->dword_stream[3]  &= input_mask->dword_stream[3];
> -	input->dword_stream[4]  &= input_mask->dword_stream[4];
> -	input->dword_stream[5]  &= input_mask->dword_stream[5];
> -	input->dword_stream[6]  &= input_mask->dword_stream[6];
> -	input->dword_stream[7]  &= input_mask->dword_stream[7];
> -	input->dword_stream[8]  &= input_mask->dword_stream[8];
> -	input->dword_stream[9]  &= input_mask->dword_stream[9];
> -	input->dword_stream[10] &= input_mask->dword_stream[10];
> +	for (i = 0; i <= 10; i++)
> +		input->dword_stream[i] &= input_mask->dword_stream[i];
> 
>  	/* record the flow_vm_vlan bits as they are a key part to the hash */
>  	flow_vm_vlan = ntohl(input->dword_stream[0]);
> 
>  	/* generate common hash dword */
> -	hi_hash_dword = ntohl(input->dword_stream[1] ^
> -				    input->dword_stream[2] ^
> -				    input->dword_stream[3] ^
> -				    input->dword_stream[4] ^
> -				    input->dword_stream[5] ^
> -				    input->dword_stream[6] ^
> -				    input->dword_stream[7] ^
> -				    input->dword_stream[8] ^
> -				    input->dword_stream[9] ^
> -				    input->dword_stream[10]);
> +	for (i = 1; i <= 10; i++)
> +		hi_dword ^= input->dword_stream[i];
> +	hi_hash_dword = ntohl(hi_dword);

If has to be worth doing these ^= at the same time as the & with the mask.
Especially if the compiler can't assume that 'input' and 'input_mask'
don't overlap - which forces some strong sequencing on the instructions.

>  	/* low dword is word swapped version of common */
>  	lo_hash_dword = (hi_hash_dword >> 16) | (hi_hash_dword << 16);
> @@ -1644,21 +1629,8 @@ void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
>  	lo_hash_dword ^= flow_vm_vlan ^ (flow_vm_vlan << 16);
> 
>  	/* Process remaining 30 bit of the key */
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(1);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(2);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(3);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(4);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(5);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(6);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(7);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(8);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(9);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(10);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(11);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(12);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(13);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(14);
> -	IXGBE_COMPUTE_BKT_HASH_ITERATION(15);
> +	for (i = 1; i <= 15; i++)
> +		IXGBE_COMPUTE_BKT_HASH_ITERATION(i);
> 
>  	/*
>  	 * Limit hash to 13 bits since max bucket count is 8K.
> --

	David
