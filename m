From: Yanjun Zhu <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv3 1/4] rds: ib: drop unnecessary rdma_reject
Date: Mon, 13 Mar 2017 14:41:10 +0800
Message-ID: <58C63F06.6090804@oracle.com>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
 <1489383828-7699-2-git-send-email-yanjun.zhu@oracle.com>
 <20170313063224.GJ2079@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170313063224.GJ2079-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 2017/3/13 14:32, Leon Romanovsky wrote:
> On Mon, Mar 13, 2017 at 01:43:45AM -0400, Zhu Yanjun wrote:
>> When rdma_accept fails, rdma_reject is called in it. As such, it is
>> not necessary to execute rdma_reject again.
> It is not always correct, according to the code, rdma_accept can fail
> and will return EINVAL and skip calling to rdma_reject.
Sure. When -EINVAL is returned, By this function cma_comp(id_priv, 
RDMA_CM_CONNECT), the connection
is lost. As such, it does not matter whether sending rdma_reject or not.

Zhu Yanjun
>
> 3725 int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
> 3726 {
> 3727         struct rdma_id_private *id_priv;
> 3728         int ret;
> 3729
> 3730         id_priv = container_of(id, struct rdma_id_private, id);
> 3731
> 3732         id_priv->owner = task_pid_nr(current);
> 3733
> 3734         if (!cma_comp(id_priv, RDMA_CM_CONNECT))
> 3735                 return -EINVAL;
> 3736
>
>
>> Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> ---
>>   net/rds/ib_cm.c | 5 ++---
>>   1 file changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
>> index ce3775a..4b9405c 100644
>> --- a/net/rds/ib_cm.c
>> +++ b/net/rds/ib_cm.c
>> @@ -677,9 +677,8 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
>>   		event->param.conn.initiator_depth);
>>
>>   	/* rdma_accept() calls rdma_reject() internally if it fails */
>> -	err = rdma_accept(cm_id, &conn_param);
>> -	if (err)
>> -		rds_ib_conn_error(conn, "rdma_accept failed (%d)\n", err);
>> +	if (rdma_accept(cm_id, &conn_param))
>> +		rds_ib_conn_error(conn, "rdma_accept failed\n");
>>
>>   out:
>>   	if (conn)
>> --
>> 2.7.4
>>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
