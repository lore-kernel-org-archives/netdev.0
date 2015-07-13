From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH] bnx2:Make various functions to have a return type of
 void in the file bnx2.c
Date: Mon, 13 Jul 2015 18:44:03 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E01947C68AA@AVMB1.qlogic.org>
References: <1436380260-19221-1-git-send-email-xerofoify@gmail.com>
 <0EA5B226BC5C7B45A71BF612AA8A019E01947ACBF7@AVMB1.qlogic.org>
 <559FB62C.2080900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"Nilesh Javali" <nilesh.javali@qlogic.com>
To: nick <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:6832 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751630AbbGMSqK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 14:46:10 -0400
In-Reply-To: <559FB62C.2080900@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sony,
> I also sent this patch and was wondering if I can get a reply on it.
> From 4a607447562bec161fd947caae5eb02c2365c58a Mon Sep
> 17 00:00:00 2001
> From: Nicholas Krause <xerofoify@gmail.com>
> Date: Wed, 8 Jul 2015 08:29:07 -0400
> Subject: [PATCH] bnx2i:Fix backwards locking scenario in the
> function  bnx2i_cleanup_task
> 
> This fixes the backwards locking scenario for unlocking the
> bottom half spinlock before calling the
> wait_for_completion_timeout on the structure pointer
> bnx2i_conn's member cmd_cleanup_cmpl for the critical region
> of this function to lock the spin_lock bottom half before
> unlocking it after the call to this function in order to have actual
> protection for the function bnx2i_cleanup_task's critical region.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/scsi/bnx2i/bnx2i_iscsi.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/scsi/bnx2i/bnx2i_iscsi.c
> b/drivers/scsi/bnx2i/bnx2i_iscsi.c
> index 7289437..619a26f 100644
> --- a/drivers/scsi/bnx2i/bnx2i_iscsi.c
> +++ b/drivers/scsi/bnx2i/bnx2i_iscsi.c
> @@ -1172,12 +1172,12 @@ static void
> bnx2i_cleanup_task(struct iscsi_task *task)
>  	if (task->state == ISCSI_TASK_ABRT_TMF) {
>  		bnx2i_send_cmd_cleanup_req(hba, task->dd_data);
> 
> -		spin_unlock_bh(&conn->session->back_lock);
> -		spin_unlock_bh(&conn->session->frwd_lock);
> +		spin_lock_bh(&conn->session->back_lock);
> +		spin_lock_bh(&conn->session->frwd_lock);
>  		wait_for_completion_timeout(&bnx2i_conn-
> >cmd_cleanup_cmpl,
> 
> 	msecs_to_jiffies(ISCSI_CMD_CLEANUP_TIMEOUT));
> -		spin_lock_bh(&conn->session->frwd_lock);
> -		spin_lock_bh(&conn->session->back_lock);
> +		spin_unlock_bh(&conn->session->frwd_lock);
> +		spin_unlock_bh(&conn->session->back_lock);
>  	}
>  	bnx2i_iscsi_unmap_sg_list(task->dd_data);
>  }
> --
> 2.1.4
> I am assuming it's wrong but you never known.
> Nick

Nick,

I have included the Qlogic ISCSI engineer to the mailing list to
review and ACK the patch. I will also follow it up with the 
ISCSI team.

Thanks,
Sony
