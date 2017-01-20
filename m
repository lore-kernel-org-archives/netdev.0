From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv3 net-next 4/4] sctp: implement sender-side procedures for
 Add Incoming/Outgoing Streams Request Parameter
Date: Fri, 20 Jan 2017 16:56:30 +0800
Message-ID: <CADvbK_dAG6gLb00VmqvuTnbXcBnK5-bSytkqd_kNEv3SxakMgw@mail.gmail.com>
References: <cover.1484845510.git.lucien.xin@gmail.com> <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
 <20170119214750.GM3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        davem <davem@davemloft.net>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:33099 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdATI4b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 03:56:31 -0500
In-Reply-To: <20170119214750.GM3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 5:47 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Fri, Jan 20, 2017 at 01:19:14AM +0800, Xin Long wrote:
>> This patch is to implement Sender-Side Procedures for the Add
>> Outgoing and Incoming Streams Request Parameter described in
>> rfc6525 section 5.1.5-5.1.6.
>>
>> It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
>> 6.3.4 for users.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  include/net/sctp/sctp.h   |  2 +
>>  include/uapi/linux/sctp.h |  7 ++++
>>  net/sctp/socket.c         | 29 ++++++++++++++
>>  net/sctp/stream.c         | 99 +++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 137 insertions(+)
>>
>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>> index b93820f..68ee1a6 100644
>> --- a/include/net/sctp/sctp.h
>> +++ b/include/net/sctp/sctp.h
>> @@ -199,6 +199,8 @@ int sctp_offload_init(void);
>>  int sctp_send_reset_streams(struct sctp_association *asoc,
>>                           struct sctp_reset_streams *params);
>>  int sctp_send_reset_assoc(struct sctp_association *asoc);
>> +int sctp_send_add_streams(struct sctp_association *asoc,
>> +                       struct sctp_add_streams *params);
>>
>>  /*
>>   * Module global variables
>> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
>> index c0bd8c3..a91a9cc 100644
>> --- a/include/uapi/linux/sctp.h
>> +++ b/include/uapi/linux/sctp.h
>> @@ -118,6 +118,7 @@ typedef __s32 sctp_assoc_t;
>>  #define SCTP_ENABLE_STREAM_RESET     118
>>  #define SCTP_RESET_STREAMS   119
>>  #define SCTP_RESET_ASSOC     120
>> +#define SCTP_ADD_STREAMS     121
>>
>>  /* PR-SCTP policies */
>>  #define SCTP_PR_SCTP_NONE    0x0000
>> @@ -1027,4 +1028,10 @@ struct sctp_reset_streams {
>>       uint16_t srs_stream_list[];     /* list if srs_num_streams is not 0 */
>>  };
>>
>> +struct sctp_add_streams {
>> +     sctp_assoc_t sas_assoc_id;
>> +     uint16_t sas_instrms;
>> +     uint16_t sas_outstrms;
>> +};
>> +
>>  #endif /* _UAPI_SCTP_H */
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index 2c5c9ca..ae0a99e 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -3838,6 +3838,32 @@ static int sctp_setsockopt_reset_assoc(struct sock *sk,
>>       return retval;
>>  }
>>
>> +static int sctp_setsockopt_add_streams(struct sock *sk,
>> +                                    char __user *optval,
>> +                                    unsigned int optlen)
>> +{
>> +     struct sctp_association *asoc;
>> +     struct sctp_add_streams params;
>> +     int retval = -EINVAL;
>> +
>> +     if (optlen != sizeof(params))
>> +             goto out;
>> +
>> +     if (copy_from_user(&params, optval, optlen)) {
>> +             retval = -EFAULT;
>> +             goto out;
>> +     }
>> +
>> +     asoc = sctp_id2assoc(sk, params.sas_assoc_id);
>> +     if (!asoc)
>> +             goto out;
>> +
>> +     retval = sctp_send_add_streams(asoc, &params);
>> +
>> +out:
>> +     return retval;
>> +}
>> +
>>  /* API 6.2 setsockopt(), getsockopt()
>>   *
>>   * Applications use setsockopt() and getsockopt() to set or retrieve
>> @@ -4013,6 +4039,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
>>       case SCTP_RESET_ASSOC:
>>               retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
>>               break;
>> +     case SCTP_ADD_STREAMS:
>> +             retval = sctp_setsockopt_add_streams(sk, optval, optlen);
>> +             break;
>>       default:
>>               retval = -ENOPROTOOPT;
>>               break;
>> diff --git a/net/sctp/stream.c b/net/sctp/stream.c
>> index b368191..ba41837 100644
>> --- a/net/sctp/stream.c
>> +++ b/net/sctp/stream.c
>> @@ -195,3 +195,102 @@ int sctp_send_reset_assoc(struct sctp_association *asoc)
>>
>>       return retval;
>>  }
>> +
>> +int sctp_send_add_streams(struct sctp_association *asoc,
>> +                       struct sctp_add_streams *params)
>> +{
>> +     struct sctp_stream *stream = asoc->stream;
>> +     struct sctp_chunk *chunk = NULL;
>> +     int retval = -EINVAL;
>> +     __u16 out, in;
>> +
>> +     if (!asoc->peer.reconf_capable ||
>> +         !(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ)) {
>> +             retval = -ENOPROTOOPT;
>> +             goto out;
>> +     }
>> +
>> +     if (asoc->strreset_outstanding) {
>> +             retval = -EINPROGRESS;
>> +             goto out;
>> +     }
>> +
>> +     out = params->sas_outstrms;
>> +     in  = params->sas_instrms;
>> +
>> +     if (!out && !in)
>
> [@]
>
>> +             goto out;
>> +
>> +     if (out) {
>> +             __u16 nums = stream->outcnt + out;
>> +
>> +             /* Check for overflow, can't use nums here */
>> +             if (stream->outcnt + out > SCTP_MAX_STREAM)
>> +                     goto out;
>
> You should do these overflow checks before doing actual work,
> preferreably at [@] mark above.
> Here it's fine, but when [*] below run, it may be too late.
>
>> +
>> +             /* Use ksize to check if stream array really needs to realloc */
>> +             if (ksize(stream->out) / sizeof(*stream->out) < nums) {
>> +                     struct sctp_stream_out *streamout;
>> +
>> +                     streamout = kcalloc(nums, sizeof(*streamout),
>> +                                         GFP_KERNEL);
>> +                     if (!streamout) {
>> +                             retval = -ENOMEM;
>> +                             goto out;
>> +                     }
>> +
>> +                     memcpy(streamout, stream->out,
>> +                            sizeof(*streamout) * stream->outcnt);
>> +
>> +                     kfree(stream->out);
>> +                     stream->out = streamout;
>> +             }
>> +
>> +             stream->outcnt = nums;
>> +     }
>> +
>> +     if (in) {
>> +             __u16 nums = stream->incnt + in;
>> +
>> +             if (stream->incnt + in > SCTP_MAX_STREAM)
>> +                     goto out;
>
> [*]
it will cause alloc unused memory, but no consistent issue if
we move outcnt/incnt after checking retval.

if we want overflow check to go ahead of the actual work, another
conditions if (in) {} if(out) {} have to be added.

>
>> +
>> +             if (ksize(stream->in) / sizeof(*stream->in) < nums) {
>> +                     struct sctp_stream_in *streamin;
>> +
>> +                     streamin = kcalloc(nums, sizeof(*streamin),
>> +                                        GFP_KERNEL);
>> +                     if (!streamin) {
>> +                             retval = -ENOMEM;
>> +                             goto out;
>> +                     }
>> +
>> +                     memcpy(streamin, stream->in,
>> +                            sizeof(*streamin) * stream->incnt);
>> +
>> +                     kfree(stream->in);
>> +                     stream->in = streamin;
>> +             }
>> +
>> +             stream->incnt = nums;
>> +     }
>> +
>> +     chunk = sctp_make_strreset_addstrm(asoc, out, in);
>> +     if (!chunk) {
>> +             retval = -ENOMEM;
>> +             goto out;
>> +     }
>> +
>> +     asoc->strreset_outstanding = !!out + !!in;
>> +     asoc->strreset_chunk = chunk;
>> +     sctp_chunk_hold(asoc->strreset_chunk);
>> +
>> +     retval = sctp_send_reconf(asoc, chunk);
>> +     if (retval) {
>> +             sctp_chunk_put(asoc->strreset_chunk);
>> +             asoc->strreset_chunk = NULL;
>> +     }
>> +
>> +out:
>> +     return retval;
>> +}
>> --
>> 2.1.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
