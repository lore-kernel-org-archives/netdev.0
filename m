From: Shannon Nelson <shannon.lee.nelson@gmail.com>
Subject: Re: [net-next 15/15] i40e: synchronize nvmupdate command and adminq subtask
Date: Mon, 14 Aug 2017 14:40:48 -0700
Message-ID: <CAP-MU4OY+gBr32S0RzDgOFJpmUVqv1D3GAXcLSReDE7TQPzCxg@mail.gmail.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com> <20170812110848.18264-17-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com,
        Stefan Assmann <sassmann@redhat.com>, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36987 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752290AbdHNVkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 17:40:49 -0400
Received: by mail-pg0-f66.google.com with SMTP id 83so12523489pgb.4
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 14:40:49 -0700 (PDT)
In-Reply-To: <20170812110848.18264-17-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 12, 2017 at 4:08 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
>
> During NVM update, state machine gets into unrecoverable state because
> i40e_clean_adminq_subtask can get scheduled after the admin queue
> command but before other state variables are updated. This causes
> incorrect input to i40e_nvmupd_check_wait_event and state transitions
> don't happen.
>
> This issue existed before but surfaced after commit 373149fc99a0
> ("i40e: Decrease the scope of rtnl lock")
>
> This fix adds locking around admin queue command and update of
> state variables so that adminq_subtask will have accurate information
> whenever it gets scheduled.
>
> Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_nvm.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
> index 6fdecd70dcbc..2cf7db2dc7cd 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
> @@ -753,6 +753,11 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
>                 hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
>         }
>
> +       /* Acquire lock to prevent race condition where adminq_task
> +        * can execute after i40e_nvmupd_nvm_read/write but before state
> +        * variables (nvm_wait_opcode, nvm_release_on_done) are updated
> +        */
> +       mutex_lock(&hw->aq.arq_mutex);
>         switch (hw->nvmupd_state) {
>         case I40E_NVMUPD_STATE_INIT:
>                 status = i40e_nvmupd_state_init(hw, cmd, bytes, perrno);
> @@ -788,6 +793,7 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
>                 *perrno = -ESRCH;
>                 break;
>         }

Perhaps I missed a patch somewhere, but I think there is still a
return statement in the middle of this switch() (INIT_WAIT and
WRITE_WAIT) that means you can leave the mutex locked.  I thought I
had seen a newer version of this patch that had this fixed

sln

> +       mutex_unlock(&hw->aq.arq_mutex);
>         return status;
>  }
>
> --
> 2.14.0
>



-- 
==============================================
Mr. Shannon Nelson         Parents can't afford to be squeamish.
