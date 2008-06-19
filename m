From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/12] benet: beclib functions
Date: Thu, 19 Jun 2008 06:33:58 -0400
Message-ID: <20080619103358.GF17697@infradead.org>
References: <20080612104312.54c39928@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:36648 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755580AbYFSKeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:34:00 -0400
Content-Disposition: inline
In-Reply-To: <20080612104312.54c39928@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +void be_chip_destroy(struct be_chip_object *chip)
> +{
> +	ASSERT(chip->ref_count == 0);
> +
> +	memset(chip, 0, sizeof(*chip));
> +	TRACE(DL_INFO, "destroying chip %p", chip);
> +}


Again memset on destory is a very bad idea.

> +}
> +
> +/*
> +    This routine removes serialization done by ChipObjectLock.
> +
> +    ChipObject      - The chip object to drop the lock for.
> +
> +    IRQL < DISPATCH_LEVEL
> +*/
> +void be_chip_unlock(struct be_chip_object *chip_object)
> +{
> +	spin_unlock_irqrestore(&chip_object->lock.lock, chip_object->lock.irql);
> +}

Please kill these locking wrappers.

> +BESTATUS be_chip_object_create(struct be_chip_object *chip)
> +{
> +	BESTATUS status = 0;
> +	bool chip_created = FALSE;
> +
> +	status = be_chip_create(chip);
> +	if (status != BE_SUCCESS)
> +		goto Error;
> +
> +	chip_created = TRUE;
> +
> +Error:
> +	if (status != BE_SUCCESS) {
> +
> +		/* Cleanup everything in case of failure. */
> +
> +		if (chip_created)
> +			be_chip_destroy(chip);
> +
> +	}
> +
> +	return status;

I'd rather write this as:

int be_chip_object_create(struct be_chip_object *chip)
{
	int error error = be_chip_create(chip);
	if (error)
		be_chip_destroy(chip);

	return error;
}

But then again I still don't get the point of this wrapper at all.

Same for various other functions in this file.

> +void _be_function_lock(struct be_function_object *pfob)
> +{
> +	spin_lock_irqsave(&pfob->lock.lock, pfob->lock.irql);
> +}
> +
> +void _be_function_unlock(struct be_function_object *pfob)
> +{
> +	spin_unlock_irqrestore(&pfob->lock.lock, pfob->lock.irql);
> +}
> +
> +u32 be_function_get_function_number(struct be_function_object *pfob)
> +{
> +	return pfob->pci_function_number;
> +}
> +
> +u32 be_function_get_function_type(struct be_function_object *pfob)
> +{
> +	return pfob->type;
> +}
> +
> +u32 be_function_get_pd_number(struct be_function_object *pfob)
> +{
> +
> +	/* only PD0 supported in Linux drivers */
> +	return 0;
> +}
> +
> +bool be_function_is_vm(struct be_function_object *pfob)
> +{
> +	return be_function_get_pd_number(pfob) > 0;
> +}

Another set of really useless wrappers.

> +BESTATUS be_initialize_library(void)
> +{
> +	SA_TRACE(DL_NOTE, "Built on " __DATE__ " " __TIME__);
> +
> +	sa_trace_set_debug_level_string(DL_HW, "hw");
> +
> +	return BE_SUCCESS;

Another unneeded wrapper.

