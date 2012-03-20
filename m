From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: rds_iw_send_ack issue in Fedora14
Date: Tue, 20 Mar 2012 20:49:13 +0530
Message-ID: <4F689FF1.3030107@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Hi Venkat,

We are seeing an issue with rds_iw_send_ack function in Fedora14 OS.

The issue is as follows:
RDS protocol requires to send an acknowledgement back to the sender for
the data it has received. RDS can send that acknowledgment by two ways:
1. It can send a piggyback ack while sending data
2. It can send only ACK packet without any data.

The issue occurs in case 2 above. For sending an ACK only packet RDS
takes another path and different variables and calls rds_iw_attempt_ack
function. This function forms RDS header by putting ACK number in it. It
puts rest of the fields in RDS header as zero. After that it calculates
checksum of that header and puts that checksum also in the header. After
this it calls ib_post_send.

Now the problem is in calculating the checksum. What happens is checksum
gets calculated perfectly fine for the "first time". For the second time
it calculates the checksum as same as first time even though ACK number
is different for the second time. Thus it results into checksum
verification failure on the peer side and connection gets torn down and
receiver request gets flushed. We see "WC Error:  status = 5 opcode = 0"
errors in dmesg on the sender side. I suspect here that it is a dma
mapping or flushing issue.

To be sure that the issue is with rds_iw_send_ack i used the same
sg_list for forming work request in rds_iw_send_ack what is being used
by the rds_iw_xmit. After this issue is resolved. So, i think something
is wrong with the dma mapping in rds_iw_send_ack function.

I only changed the following line in rds_iw_recv_init_ack and it started
working.

-       sge->addr = ic->i_ack_dma;
+       sge->addr = ic->i_send_hdrs_dma;

Interestingly, the issue occurs only on Fedora14(2.6.35.6-45) OS. The
issue does not occur with both RHEL6.0(2.6.32-71.el6.x86_64) and
RHEL6.1(2.6.32-131.el6.x86_64) OS. The RDS module code is similar for
both the OSes.

Can you please share your thoughts?

Thanks,
Vipul Pandya
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
