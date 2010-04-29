From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 5/5] sctp: Fix oops when sending queued ASCONF chunks
Date: Thu, 29 Apr 2010 10:26:52 -0400
Message-ID: <4BD9972C.4000103@hp.com>
References: <1272480442-32673-1-git-send-email-vladislav.yasevich@hp.com> <1272480442-32673-6-git-send-email-vladislav.yasevich@hp.com> <4BD99310.8020207@research.ait.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-sctp@vger.kernel.org, Yuansong Qiao <ysqiao@research.ait.ie>
To: Shuaijun Zhang <szhang@research.ait.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:27840 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757639Ab0D3Que (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:50:34 -0400
In-Reply-To: <4BD99310.8020207@research.ait.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Shuaijun Zhang wrote:
> Vlad Yasevich wrote:
>> When we finish processing ASCONF_ACK chunk, we try to send
>> the next queued ASCONF.  This action runs the sctp state
>> machine recursively and it's not prepared to do so.
>>
>> kernel BUG at kernel/timer.c:790!
>> invalid opcode: 0000 [#1] SMP
>> last sysfs file: /sys/module/ipv6/initstate
>> Modules linked in: sha256_generic sctp libcrc32c ipv6 dm_multipath
>> uinput 8139too i2c_piix4 8139cp mii i2c_core pcspkr virtio_net joydev
>> floppy virtio_blk virtio_pci [last unloaded: scsi_wait_scan]
>>
>> Pid: 0, comm: swapper Not tainted 2.6.34-rc4 #15 /Bochs
>> EIP: 0060:[<c044a2ef>] EFLAGS: 00010286 CPU: 0
>> EIP is at add_timer+0xd/0x1b
>> EAX: cecbab14 EBX: 000000f0 ECX: c0957b1c EDX: 03595cf4
>> ESI: cecba800 EDI: cf276f00 EBP: c0957aa0 ESP: c0957aa0
>>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
>> Process swapper (pid: 0, ti=c0956000 task=c0988ba0 task.ti=c0956000)
>> Stack:
>>  c0957ae0 d1851214 c0ab62e4 c0ab5f26 0500ffff 00000004 00000005 00000004
>> <0> 00000000 d18694fd 00000004 1666b892 cecba800 cecba800 c0957b14
>> 00000004
>> <0> c0957b94 d1851b11 ceda8b00 cecba800 cf276f00 00000001 c0957b14
>> 000000d0
>>   
> According to the call trace below, it seems that our modification did
> not take affect.
> sctp_primitive_ASCONF should be invoked after sctp_side_effects().
> Our code fixed the same problem in kernel 2.6.27.28.
> Not sure about the difference between 2.6.34-rc4 kernel and 2.6.27.28
> kernel.

This is the patch that you sent me, that included comments that Wei made on
the list.  It corrects this problem and will be pushed back to stable tries
that are still maintained.

The call trace in the commit log is for reference.  The patch has been tested
and resolves the issue you reported.

-vlad

>> Call Trace:
>>  [<d1851214>] ? sctp_side_effects+0x607/0xdfc [sctp]
>>  [<d1851b11>] ? sctp_do_sm+0x108/0x159 [sctp]
>>  [<d1863386>] ? sctp_pname+0x0/0x1d [sctp]
>>  [<d1861a56>] ? sctp_primitive_ASCONF+0x36/0x3b [sctp]        <---
>> sctp_side_effects() should show up here before send next asconf
>>  [<d185657c>] ? sctp_process_asconf_ack+0x2a4/0x2d3 [sctp]
>>  [<d184e35c>] ? sctp_sf_do_asconf_ack+0x1dd/0x2b4 [sctp]
>>  [<d1851ac1>] ? sctp_do_sm+0xb8/0x159 [sctp]
>>  [<d1863334>] ? sctp_cname+0x0/0x52 [sctp]
>>  [<d1854377>] ? sctp_assoc_bh_rcv+0xac/0xe1 [sctp]
>>  [<d1858f0f>] ? sctp_inq_push+0x2d/0x30 [sctp]
>>  [<d186329d>] ? sctp_rcv+0x797/0x82e [sctp]
>>
>> Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>> Signed-off-by: Yuansong Qiao <ysqiao@research.ait.ie>
>> Signed-off-by: Shuaijun Zhang <szhang@research.ait.ie>
>> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>> ---
>>  include/net/sctp/command.h |    1 +
>>  net/sctp/sm_make_chunk.c   |   15 ---------------
>>  net/sctp/sm_sideeffect.c   |   26 ++++++++++++++++++++++++++
>>  net/sctp/sm_statefuns.c    |    8 +++++++-
>>  4 files changed, 34 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
>> index 8be5135..2c55a7e 100644
>> --- a/include/net/sctp/command.h
>> +++ b/include/net/sctp/command.h
>> @@ -107,6 +107,7 @@ typedef enum {
>>      SCTP_CMD_T1_RETRAN,     /* Mark for retransmission after T1
>> timeout  */
>>      SCTP_CMD_UPDATE_INITTAG, /* Update peer inittag */
>>      SCTP_CMD_SEND_MSG,     /* Send the whole use message */
>> +    SCTP_CMD_SEND_NEXT_ASCONF, /* Send the next ASCONF after ACK */
>>      SCTP_CMD_LAST
>>  } sctp_verb_t;
>>  
>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index f6fc5c1..0fd5b4c 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -3318,21 +3318,6 @@ int sctp_process_asconf_ack(struct
>> sctp_association *asoc,
>>      sctp_chunk_free(asconf);
>>      asoc->addip_last_asconf = NULL;
>>  
>> -    /* Send the next asconf chunk from the addip chunk queue. */
>> -    if (!list_empty(&asoc->addip_chunk_list)) {
>> -        struct list_head *entry = asoc->addip_chunk_list.next;
>> -        asconf = list_entry(entry, struct sctp_chunk, list);
>> -
>> -        list_del_init(entry);
>> -
>> -        /* Hold the chunk until an ASCONF_ACK is received. */
>> -        sctp_chunk_hold(asconf);
>> -        if (sctp_primitive_ASCONF(asoc, asconf))
>> -            sctp_chunk_free(asconf);
>> -        else
>> -            asoc->addip_last_asconf = asconf;
>> -    }
>> -
>>      return retval;
>>  }
>>  
>> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>> index 4c5bed9..d5ae450 100644
>> --- a/net/sctp/sm_sideeffect.c
>> +++ b/net/sctp/sm_sideeffect.c
>> @@ -962,6 +962,29 @@ static int sctp_cmd_send_msg(struct
>> sctp_association *asoc,
>>  }
>>  
>>  
>> +/* Sent the next ASCONF packet currently stored in the association.
>> + * This happens after the ASCONF_ACK was succeffully processed.
>> + */
>> +static void sctp_cmd_send_asconf(struct sctp_association *asoc)
>> +{
>> +    /* Send the next asconf chunk from the addip chunk
>> +     * queue.
>> +     */
>> +    if (!list_empty(&asoc->addip_chunk_list)) {
>> +        struct list_head *entry = asoc->addip_chunk_list.next;
>> +        struct sctp_chunk *asconf = list_entry(entry,
>> +                        struct sctp_chunk, list);
>> +        list_del_init(entry);
>> +
>> +        /* Hold the chunk until an ASCONF_ACK is received. */
>> +        sctp_chunk_hold(asconf);
>> +        if (sctp_primitive_ASCONF(asoc, asconf))
>> +            sctp_chunk_free(asconf);
>> +        else
>> +            asoc->addip_last_asconf = asconf;
>> +    }
>> +}
>> +
>>  
>>  /* These three macros allow us to pull the debugging code out of the
>>   * main flow of sctp_do_sm() to keep attention focused on the real
>> @@ -1617,6 +1640,9 @@ static int sctp_cmd_interpreter(sctp_event_t
>> event_type,
>>              }
>>              error = sctp_cmd_send_msg(asoc, cmd->obj.msg);
>>              break;
>> +        case SCTP_CMD_SEND_NEXT_ASCONF:
>> +            sctp_cmd_send_asconf(asoc);
>> +            break;
>>          default:
>>              printk(KERN_WARNING "Impossible command: %u, %p\n",
>>                     cmd->verb, cmd->obj.ptr);
>> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
>> index abf601a..24b2cd5 100644
>> --- a/net/sctp/sm_statefuns.c
>> +++ b/net/sctp/sm_statefuns.c
>> @@ -3676,8 +3676,14 @@ sctp_disposition_t sctp_sf_do_asconf_ack(const
>> struct sctp_endpoint *ep,
>>                  SCTP_TO(SCTP_EVENT_TIMEOUT_T4_RTO));
>>  
>>          if (!sctp_process_asconf_ack((struct sctp_association *)asoc,
>> -                         asconf_ack))
>> +                         asconf_ack)) {
>> +            /* Successfully processed ASCONF_ACK.  We can
>> +             * release the next asconf if we have one.
>> +             */
>> +            sctp_add_cmd_sf(commands, SCTP_CMD_SEND_NEXT_ASCONF,
>> +                    SCTP_NULL());
>>              return SCTP_DISPOSITION_CONSUME;
>> +        }
>>  
>>          abort = sctp_make_abort(asoc, asconf_ack,
>>                      sizeof(sctp_errhdr_t));
>>   
> 
