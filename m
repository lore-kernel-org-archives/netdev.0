From: "Gaurav Aggarwal" <grv.aggarwal@gmail.com>
Subject: Re: Bad TCP checksum error
Date: Fri, 26 Oct 2007 21:33:07 +0530
Message-ID: <1a41e0840710260903w33516f62kc53e5eb56e424d69@mail.gmail.com>
References: <1a41e0840710260041u4ebeb1e3h521e740a78f7e0bf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_7158_9973493.1193414587575"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	davidsen@tmr.com, "Gaurav Aggarwal" <grv.aggarwal@gmail.com>
To: linux-net-owner@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <1a41e0840710260041u4ebeb1e3h521e740a78f7e0bf@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_7158_9973493.1193414587575
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi All,

I have dome some changes in the code. Now instead of calculating the
TCP checksum from scratch, I was just recalculating it by incremental
update as mentioned in RFC 1624. Good thing is that now I was able to
get the correct IP header checksum but still TCP checksum value is
corrupted. Interesting thing is, this time the difference in checksum
is exactly the same as that of difference in original and modified
packet header. What I mean to say is that I was changing the
destination IP from "10.102.35.22" to "10.102.35.24" and the
difference in tcp checksum (expected and computed) is coming as 0x02.
Attached is the modified source code and tcpdump. Any help will be
really appreciated.

On 10/26/07, Gaurav Aggarwal <grv.aggarwal@gmail.com> wrote:
> Hi,
>
> I wrote a program where I am using the nfnetlink and netfilter_queue
> model to capture the packet. After that I just change the destination
> address of the packet and insert it back into the ip stack. But after
> inserting the packet I am getting a bad TCP checksum error. Even I am
> getting the same error for IP header checksum. Attached is the source
> code and tcpdump on host machine.
>
> /* Source Code */
> /* Compile with gcc -lnfnetlink -lnetfilter_queue  */
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
> #include <netinet/in.h>
> #include <netinet/ip.h>
> #include <netinet/tcp.h>
> #include <linux/netfilter.h>            /* for NF_ACCEPT */
> #include <arpa/inet.h>
>
> #include <libnetfilter_queue/libnetfilter_queue.h>
>
> #define  BUFSIZE  2048
>
> struct in_addr foreign;
> struct in_addr local;
>
> struct queued_pckt {
>         char *payload;
>         int payload_len;
> };
>
> struct pseudohdr
> {
>         unsigned long ip_src ;
>         unsigned long ip_dst ;
>         unsigned char reserve ;
>         unsigned char type ;
>         unsigned short length;
> } ;
>
> unsigned short checksum(unsigned short *addr, unsigned int count) {
>         /* Compute Internet Checksum for "count" bytes beginning at location "addr".
>          * Algorithm is simple, using a 32-bit accumulator (sum),
>          * we add sequential 16-bit words to it, and at the end, fold back
>          * all the carry bits from the top 16 bits into the lower 16 bits.
>         */
>        register long sum = 0;
>        unsigned short result;
>
>         while (count > 1)  {
>            /*  This is the inner loop */
>                sum += * addr++;
>                count -= 2;
>        }
>            /*  Add left-over byte, if any */
>        if (count == 1)
>        {
>                 result = 0;     //make sure top half is zero
>                 * (unsigned char *) (&result) = *(unsigned char *)addr;
>                 sum += result;
>         }
>
>         /*
>          * Add back carry outs from top 16 bits to low 16 bits.
>          * Fold 32-bit sum to 16 bits
>         */
>
>        sum = (sum >> 16) + (sum & 0xffff);      /* add high-16 to low-16 */
>        sum += (sum >> 16);                      /* add carry */
>
>        result = ~sum;                   /* ones-complement, then truncate to 16 bits */
>        return (result);
> }
>
>
> unsigned short get_tcp_chksum (struct tcphdr *orig_tcphdr, struct
> iphdr *orig_iphdr )
> {
>         struct pseudohdr pseudoh ;
>
>         unsigned int total_len = ntohs(orig_iphdr->tot_len);
>         int tcpopt_len = (orig_tcphdr->doff * 4) - 20;
>         int tcpdata_len = total_len - (orig_tcphdr->doff * 4) - (orig_iphdr->ihl * 4);
>
>         pseudoh.ip_src = orig_iphdr->saddr ;
>         pseudoh.ip_dst = orig_iphdr->daddr ;
>         pseudoh.reserve = 0 ;
>         pseudoh.type = orig_iphdr->protocol ;
>         pseudoh.length = htons (sizeof (struct tcphdr) + tcpopt_len + tcpdata_len) ;
>
>         int totaltcp_len = sizeof(struct pseudohdr) + sizeof(struct tcphdr) +
> tcpopt_len + tcpdata_len;
>
>         unsigned short *tcp = (unsigned short *)malloc (totaltcp_len);
>
>         memcpy ((unsigned char *)tcp, &pseudoh, sizeof(struct pseudohdr));
>         memcpy ((unsigned char *)tcp + sizeof(struct pseudohdr), (unsigned
> char *)orig_tcphdr, sizeof(struct tcphdr));
>         if (tcpopt_len > 0)
>                 memcpy ((unsigned char *)tcp + sizeof(struct pseudohdr) +
> sizeof(struct tcphdr), (unsigned char *)orig_iphdr + (orig_iphdr->ihl
> * 4) + sizeof(struct tcphdr), tcpopt_len);
>
>         if (tcpdata_len > 0)
>                 memcpy ((unsigned char *)tcp + sizeof(struct pseudohdr) +
> sizeof(struct tcphdr) + tcpopt_len, (unsigned char *)orig_tcphdr +
> (orig_tcphdr->doff * 4), tcpdata_len);
>
> #if 0
>         printf("pseudo length: %d\n",pseudoh.length);
>         printf("tcp hdr length: %d\n",orig_tcphdr->doff*4);
>         printf("tcp hdr struct length: %d\n",sizeof(struct tcphdr));
>         printf("tcphdr->doff = %d, tcp opt length:
> %d\n",orig_tcphdr->doff,tcpopt_len);
>         printf("tcp total+psuedo length: %d\n",totaltcp_len);
>
>         fflush(stdout);
>
>         printf("tcp data len: %d, data start %u\n",
> tcpdata_len,orig_tcphdr + (orig_tcphdr->doff*4));
> #endif
>
>         return (checksum (tcp, totaltcp_len)) ;
> }
>
> static void filter(
>         unsigned char *packet, unsigned int payload_len)
> {
>         struct iphdr *iphdr;
>         struct tcphdr *tcphdr;
>
>         printf ("in filter function\n");
>
>         iphdr = (struct iphdr *)packet;
>         /* check need some datas */
>         if (payload_len < sizeof(struct iphdr) + sizeof(struct tcphdr)) {
>                 return;
>         }
>         /* check IP version */
>         if (iphdr->protocol == IPPROTO_TCP)
>         {
>                 tcphdr = (struct tcphdr *)(((u_int32_t *)packet) + 4 * iphdr->ihl);
>
>                 if (iphdr->daddr == foreign.s_addr)
>                 {
>                         printf ("packet DEST addr = %s\n",inet_ntoa(foreign));
>                         fprintf (stderr, "changing pkt's DEST addr from FOREIGN to LOCAL\n");
>                         iphdr->daddr = local.s_addr;
>                         tcphdr->check = 0 ; // checksum will be calculated later
>                         iphdr->check = checksum(
>                                 (unsigned short *)iphdr,
>                                 sizeof(struct iphdr));
>                         tcphdr->check = get_tcp_chksum(
>                                 tcphdr,
>                                 iphdr);
>                 }
>         }
>
> }
>
> static int cb(struct nfq_q_handle *qh, struct nfgenmsg *nfmsg,
>               struct nfq_data *nfa, void *data)
> {
>         int id = 0;
>         struct nfqnl_msg_packet_hdr *ph;
>         struct queued_pckt q_pckt;
>         u_int32_t mark,ifi;
>         int ret;
>         char *payload;
>
>         printf("entering callback\n");
>         ph = nfq_get_msg_packet_hdr(nfa);
>         if (ph){
>                 id = ntohl(ph->packet_id);
>                 printf("hw_protocol=0x%04x hook=%u id=%u ",
>                         ntohs(ph->hw_protocol), ph->hook, id);
>         }
>
>         mark = nfq_get_nfmark(nfa);
>         if (mark)
>                 printf("mark=%u ", mark);
>
>         ifi = nfq_get_indev(nfa);
>         if (ifi)
>                 printf("indev=%u ", ifi);
>
>         ifi = nfq_get_outdev(nfa);
>         if (ifi)
>                 printf("outdev=%u ", ifi);
>
>         q_pckt.payload_len = nfq_get_payload(nfa, &(q_pckt.payload));
>         if (q_pckt.payload_len >= 0)
>         {
>                 printf("payload_len=%d ", q_pckt.payload_len);
>                 fputc('\n', stdout);
>                 filter((unsigned char *)q_pckt.payload, q_pckt.payload_len);
>         }
>
>         printf("setting verdict of packet id %d\n",id);
>         return nfq_set_verdict(qh, id, NF_ACCEPT, q_pckt.payload_len, q_pckt.payload);
> }
>
> int main(int argc, char **argv)
> {
>         struct nfq_handle *h;
>         struct nfq_q_handle *qh;
>         struct nfnl_handle *nh;
>         int fd;
>         int rv;
>         unsigned char buf[BUFSIZE];
>
>         if (argc == 1)
>         {
>                 inet_aton("10.102.130.222", &(foreign));
>                 inet_aton("10.102.130.105", &(local));
>         } else if (argc == 3)
>         {
>                 inet_aton(argv[1], &(foreign));
>                 inet_aton(argv[2], &(local));
>         }
>         else
>         {
>                 printf("Usage: argv[0] [foreign_addr local_addr]\n");
>                 return 0;
>         }
>
>         printf("opening library handle\n");
>         h = nfq_open();
>         if (!h) {
>                 fprintf(stderr, "error during nfq_open()\n");
>                 return 0;
>         }
>
>         printf("unbinding existing nf_queue handler for AF_INET (if any)\n");
>         if (nfq_unbind_pf(h, AF_INET) < 0) {
>                 fprintf(stderr, "error during nfq_unbind_pf()\n");
>                 exit(1);
>         }
>
>         printf("binding nfnetlink_queue as nf_queue handler for AF_INET\n");
>         if (nfq_bind_pf(h, AF_INET) < 0) {
>                 fprintf(stderr, "error during nfq_bind_pf()\n");
>                 exit(1);
>         }
>
>         printf("binding this socket to queue '0'\n");
>         qh = nfq_create_queue(h,  0, &cb, NULL);
>         if (!qh) {
>                 fprintf(stderr, "error during nfq_create_queue()\n");
>                 exit(1);
>         }
>
>         printf("setting copy_packet mode\n");
>         if (nfq_set_mode(qh, NFQNL_COPY_PACKET, BUFSIZE) < 0) {
>                 fprintf(stderr, "can't set packet_copy mode\n");
>                 exit(1);
>         }
>
>         nh = nfq_nfnlh(h);
>         fd = nfnl_fd(nh);
>
>         while ((rv = recv(fd, buf, BUFSIZE, 0)) && rv >= 0) {
>                 printf("pkt received\n");
>                 nfq_handle_packet(h, buf, rv);
>                 printf("pkt handled\n");
>         }
>
>         printf("unbinding from queue 0\n");
>         nfq_destroy_queue(qh);
>
>         printf("closing library handle\n");
>         nfq_close(h);
>
>         exit(0);
> }
> /* end - Source Code */
>
> /* TCP dump */
> tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
> 12:59:36.706161 IP (tos 0x0, ttl  64, id 61974, offset 0, flags [DF],
> proto: TCP (6), length: 60, bad cksum 75 (->8e24)!) 10.102.35.76.36898
> > 10.102.130.105.colubris: S, cksum 0xc6d5 (incorrect (-> 0xc74a),
> 366446207:366446207(0) win 5840 <mss 1460,sackOK,timestamp 14775401
> 0,nop,wscale 6>
>         0x0000:  0012 010a 5f4c 000b cd3a 5bfb 0800 4500
>         0x0010:  003c f216 4000 4006 0075 0a66 234c 0a66
>         0x0020:  8269 9022 0da2 15d7 867f 0000 0000 a002
>         0x0030:  16d0 c6d5 0000 0204 05b4 0402 080a 00e1
>         0x0040:  7469 0000 0000 0103 0306
> 12:59:39.708619 IP (tos 0x0, ttl  64, id 61975, offset 0, flags [DF],
> proto: TCP (6), length: 60, bad cksum 75 (->8e23)!) 10.102.35.76.36898
> > 10.102.130.105.colubris: S, cksum 0xc3e7 (incorrect (-> 0xc45c),
> 366446207:366446207(0) win 5840 <mss 1460,sackOK,timestamp 14776151
> 0,nop,wscale 6>
>         0x0000:  0012 010a 5f4c 000b cd3a 5bfb 0800 4500
>         0x0010:  003c f217 4000 4006 0075 0a66 234c 0a66
>         0x0020:  8269 9022 0da2 15d7 867f 0000 0000 a002
>         0x0030:  16d0 c3e7 0000 0204 05b4 0402 080a 00e1
>         0x0040:  7757 0000 0000 0103 0306
>
> 2 packets captured
> 4 packets received by filter
> 0 packets dropped by kernel
> /* End - TCP dump */
>
> Attached is the dump for ethreal also.
>
> --
> Regards,
> Gaurav Aggarwal
>
>


-- 
Regards,
Gaurav Aggarwal

------=_Part_7158_9973493.1193414587575
Content-Type: application/octet-stream; name=nfq_test_modified.c
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f88w1z0h
Content-Disposition: attachment; filename=nfq_test_modified.c

LyogQ29tcGlsZSB3aXRoIGdjYyAtbG5mbmV0bGluayAtbG5ldGZpbHRlcl9xdWV1ZSAgKi8NCiNp
bmNsdWRlIDxzdGRpby5oPg0KI2luY2x1ZGUgPHN0ZGxpYi5oPg0KI2luY2x1ZGUgPHVuaXN0ZC5o
Pg0KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4NCiNpbmNsdWRlIDxuZXRpbmV0L2lwLmg+DQojaW5j
bHVkZSA8bmV0aW5ldC90Y3AuaD4NCiNpbmNsdWRlIDxsaW51eC9uZXRmaWx0ZXIuaD4JCS8qIGZv
ciBORl9BQ0NFUFQgKi8NCiNpbmNsdWRlIDxhcnBhL2luZXQuaD4NCg0KI2luY2x1ZGUgPGxpYm5l
dGZpbHRlcl9xdWV1ZS9saWJuZXRmaWx0ZXJfcXVldWUuaD4NCg0KI2RlZmluZSAgQlVGU0laRSAg
MjA0OA0KDQpzdHJ1Y3QgaW5fYWRkciBmb3JlaWduOw0Kc3RydWN0IGluX2FkZHIgbG9jYWw7DQoN
CnN0cnVjdCBxdWV1ZWRfcGNrdCB7DQoJY2hhciAqcGF5bG9hZDsNCglpbnQgcGF5bG9hZF9sZW47
DQp9Ow0KDQppbmxpbmUgdV9pbnQxNl90IGNoZWNrc3VtX3VwZGF0ZV8zMigNCgl1X2ludDE2X3Qg
b2xkX2NoZWNrLA0KCXVfaW50MzJfdCBvbGQsDQoJdV9pbnQzMl90IG5ldykNCnsNCgl1X2ludDMy
X3QgbDsNCg0KCW9sZF9jaGVjayA9IH5vbGRfY2hlY2s7DQoJb2xkID0gfm9sZDsNCg0KCWwgPSAo
dV9pbnQzMl90KW9sZF9jaGVjayArICgob2xkID4+IDE2KSArIChvbGQgJiAweGZmZmYpKSArICgo
bmV3ID4+IDE2KSArIChuZXcgJiAweGZmZmYpKTsNCglyZXR1cm4gfigodV9pbnQxNl90KSgobCA+
PiAxNikgKyAobCAmIDB4ZmZmZikpKTsNCn0NCg0Kc3RhdGljIHZvaWQgZmlsdGVyKA0KCXVuc2ln
bmVkIGNoYXIgKnBhY2tldCwgdW5zaWduZWQgaW50IHBheWxvYWRfbGVuKQ0Kew0KCXN0cnVjdCBp
cGhkciAqaXBoZHI7DQoJc3RydWN0IHRjcGhkciAqdGNwaGRyOw0KDQoJcHJpbnRmICgiaW4gZmls
dGVyIGZ1bmN0aW9uXG4iKTsNCg0KCWlwaGRyID0gKHN0cnVjdCBpcGhkciAqKXBhY2tldDsNCgkv
KiBjaGVjayBuZWVkIHNvbWUgZGF0YXMgKi8NCglpZiAocGF5bG9hZF9sZW4gPCBzaXplb2Yoc3Ry
dWN0IGlwaGRyKSArIHNpemVvZihzdHJ1Y3QgdGNwaGRyKSkgew0KCQlyZXR1cm47DQoJfQ0KCS8q
IGNoZWNrIElQIHZlcnNpb24gKi8NCglpZiAoaXBoZHItPnByb3RvY29sID09IElQUFJPVE9fVENQ
KQ0KCXsNCgkJdGNwaGRyID0gKHN0cnVjdCB0Y3BoZHIgKikoKCh1X2ludDMyX3QgKilwYWNrZXQp
ICsgNCAqIGlwaGRyLT5paGwpOw0KDQoJCWlmIChpcGhkci0+ZGFkZHIgPT0gZm9yZWlnbi5zX2Fk
ZHIpDQoJCXsNCgkJCXByaW50ZiAoInBhY2tldCBERVNUIGFkZHIgPSAlc1xuIixpbmV0X250b2Eo
Zm9yZWlnbikpOw0KCQkJcHJpbnRmICgibG9jYWwgYWRkciA9ICVzXG4iLGluZXRfbnRvYShsb2Nh
bCkpOw0KCQkJZnByaW50ZiAoc3RkZXJyLCAiY2hhbmdpbmcgcGt0J3MgREVTVCBhZGRyIGZyb20g
Rk9SRUlHTiB0byBMT0NBTFxuIik7DQoJCQlpcGhkci0+Y2hlY2sgPSBjaGVja3N1bV91cGRhdGVf
MzIoDQoJCQkJaXBoZHItPmNoZWNrLA0KCQkJCWlwaGRyLT5kYWRkciwNCgkJCQlsb2NhbC5zX2Fk
ZHIpOw0KCQkJdGNwaGRyLT5jaGVjayA9IGNoZWNrc3VtX3VwZGF0ZV8zMigNCgkJCQl0Y3BoZHIt
PmNoZWNrLA0KCQkJCWlwaGRyLT5kYWRkciwNCgkJCQlsb2NhbC5zX2FkZHIpOw0KCQkJaXBoZHIt
PmRhZGRyID0gbG9jYWwuc19hZGRyOw0KCQl9DQoJfQ0KDQp9DQoNCnN0YXRpYyBpbnQgY2Ioc3Ry
dWN0IG5mcV9xX2hhbmRsZSAqcWgsIHN0cnVjdCBuZmdlbm1zZyAqbmZtc2csDQoJICAgICAgc3Ry
dWN0IG5mcV9kYXRhICpuZmEsIHZvaWQgKmRhdGEpDQp7DQoJaW50IGlkID0gMDsNCglzdHJ1Y3Qg
bmZxbmxfbXNnX3BhY2tldF9oZHIgKnBoOw0KCXN0cnVjdCBxdWV1ZWRfcGNrdCBxX3Bja3Q7DQoJ
dV9pbnQzMl90IG1hcmssaWZpOyANCglpbnQgcmV0Ow0KCWNoYXIgKnBheWxvYWQ7DQoJDQoJcHJp
bnRmKCJlbnRlcmluZyBjYWxsYmFja1xuIik7DQoJcGggPSBuZnFfZ2V0X21zZ19wYWNrZXRfaGRy
KG5mYSk7DQoJaWYgKHBoKXsNCgkJaWQgPSBudG9obChwaC0+cGFja2V0X2lkKTsNCgkJcHJpbnRm
KCJod19wcm90b2NvbD0weCUwNHggaG9vaz0ldSBpZD0ldSAiLA0KCQkJbnRvaHMocGgtPmh3X3By
b3RvY29sKSwgcGgtPmhvb2ssIGlkKTsNCgl9DQoJDQoJbWFyayA9IG5mcV9nZXRfbmZtYXJrKG5m
YSk7DQoJaWYgKG1hcmspDQoJCXByaW50ZigibWFyaz0ldSAiLCBtYXJrKTsNCg0KCWlmaSA9IG5m
cV9nZXRfaW5kZXYobmZhKTsNCglpZiAoaWZpKQ0KCQlwcmludGYoImluZGV2PSV1ICIsIGlmaSk7
DQoNCglpZmkgPSBuZnFfZ2V0X291dGRldihuZmEpOw0KCWlmIChpZmkpDQoJCXByaW50Zigib3V0
ZGV2PSV1ICIsIGlmaSk7DQoNCglxX3Bja3QucGF5bG9hZF9sZW4gPSBuZnFfZ2V0X3BheWxvYWQo
bmZhLCAmKHFfcGNrdC5wYXlsb2FkKSk7DQoJaWYgKHFfcGNrdC5wYXlsb2FkX2xlbiA+PSAwKQ0K
CXsNCgkJcHJpbnRmKCJwYXlsb2FkX2xlbj0lZCAiLCBxX3Bja3QucGF5bG9hZF9sZW4pOw0KCQlm
cHV0YygnXG4nLCBzdGRvdXQpOw0KCQlmaWx0ZXIoKHVuc2lnbmVkIGNoYXIgKilxX3Bja3QucGF5
bG9hZCwgcV9wY2t0LnBheWxvYWRfbGVuKTsNCgl9DQoJDQoJcHJpbnRmKCJzZXR0aW5nIHZlcmRp
Y3Qgb2YgcGFja2V0IGlkICVkXG4iLGlkKTsNCglyZXR1cm4gbmZxX3NldF92ZXJkaWN0KHFoLCBp
ZCwgTkZfQUNDRVBULCBxX3Bja3QucGF5bG9hZF9sZW4sIHFfcGNrdC5wYXlsb2FkKTsNCn0NCg0K
aW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKiphcmd2KQ0Kew0KCXN0cnVjdCBuZnFfaGFuZGxlICpo
Ow0KCXN0cnVjdCBuZnFfcV9oYW5kbGUgKnFoOw0KCXN0cnVjdCBuZm5sX2hhbmRsZSAqbmg7DQoJ
aW50IGZkOw0KCWludCBydjsNCgl1bnNpZ25lZCBjaGFyIGJ1ZltCVUZTSVpFXTsNCg0KCWluZXRf
YXRvbigiMTAuMTAyLjM1LjIyIiwgJihmb3JlaWduKSk7DQoJaW5ldF9hdG9uKCIxMC4xMDIuMzUu
MjQiLCAmKGxvY2FsKSk7DQoNCglwcmludGYoIm9wZW5pbmcgbGlicmFyeSBoYW5kbGVcbiIpOw0K
CWggPSBuZnFfb3BlbigpOw0KCWlmICghaCkgew0KCQlmcHJpbnRmKHN0ZGVyciwgImVycm9yIGR1
cmluZyBuZnFfb3BlbigpXG4iKTsNCgkJZXhpdCgxKTsNCgl9DQoNCglwcmludGYoInVuYmluZGlu
ZyBleGlzdGluZyBuZl9xdWV1ZSBoYW5kbGVyIGZvciBBRl9JTkVUIChpZiBhbnkpXG4iKTsNCglp
ZiAobmZxX3VuYmluZF9wZihoLCBBRl9JTkVUKSA8IDApIHsNCgkJZnByaW50ZihzdGRlcnIsICJl
cnJvciBkdXJpbmcgbmZxX3VuYmluZF9wZigpXG4iKTsNCgkJZXhpdCgxKTsNCgl9DQoNCglwcmlu
dGYoImJpbmRpbmcgbmZuZXRsaW5rX3F1ZXVlIGFzIG5mX3F1ZXVlIGhhbmRsZXIgZm9yIEFGX0lO
RVRcbiIpOw0KCWlmIChuZnFfYmluZF9wZihoLCBBRl9JTkVUKSA8IDApIHsNCgkJZnByaW50Zihz
dGRlcnIsICJlcnJvciBkdXJpbmcgbmZxX2JpbmRfcGYoKVxuIik7DQoJCWV4aXQoMSk7DQoJfQ0K
DQoJcHJpbnRmKCJiaW5kaW5nIHRoaXMgc29ja2V0IHRvIHF1ZXVlICcwJ1xuIik7DQoJcWggPSBu
ZnFfY3JlYXRlX3F1ZXVlKGgsICAwLCAmY2IsIE5VTEwpOw0KCWlmICghcWgpIHsNCgkJZnByaW50
ZihzdGRlcnIsICJlcnJvciBkdXJpbmcgbmZxX2NyZWF0ZV9xdWV1ZSgpXG4iKTsNCgkJZXhpdCgx
KTsNCgl9DQoNCglwcmludGYoInNldHRpbmcgY29weV9wYWNrZXQgbW9kZVxuIik7DQoJaWYgKG5m
cV9zZXRfbW9kZShxaCwgTkZRTkxfQ09QWV9QQUNLRVQsIEJVRlNJWkUpIDwgMCkgew0KCQlmcHJp
bnRmKHN0ZGVyciwgImNhbid0IHNldCBwYWNrZXRfY29weSBtb2RlXG4iKTsNCgkJZXhpdCgxKTsN
Cgl9DQoNCgluaCA9IG5mcV9uZm5saChoKTsNCglmZCA9IG5mbmxfZmQobmgpOw0KDQoJd2hpbGUg
KChydiA9IHJlY3YoZmQsIGJ1ZiwgQlVGU0laRSwgMCkpICYmIHJ2ID49IDApIHsNCgkJcHJpbnRm
KCJwa3QgcmVjZWl2ZWRcbiIpOw0KCQluZnFfaGFuZGxlX3BhY2tldChoLCBidWYsIHJ2KTsNCgkJ
cHJpbnRmKCJwa3QgaGFuZGxlZFxuIik7DQoJfQ0KDQoJcHJpbnRmKCJ1bmJpbmRpbmcgZnJvbSBx
dWV1ZSAwXG4iKTsNCgluZnFfZGVzdHJveV9xdWV1ZShxaCk7DQoNCglwcmludGYoImNsb3Npbmcg
bGlicmFyeSBoYW5kbGVcbiIpOw0KCW5mcV9jbG9zZShoKTsNCg0KCWV4aXQoMCk7DQp9DQo=
------=_Part_7158_9973493.1193414587575
Content-Type: text/plain; name=tcpdump.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f88w39lk
Content-Disposition: attachment; filename=tcpdump.txt

dGNwZHVtcDogbGlzdGVuaW5nIG9uIGV0aDAKMjE6MDA6MDEuNDkwOTIwIDEwLjEwMi4zNS43Ni4z
ODA2NyA+IDEwLjEwMi4zNS4yNC4zNDkwOiBTIFtiYWQgdGNwIGNrc3VtIGZkZmYhXSAxMDY0Njg5
NzQ1OjEwNjQ2ODk3NDUoMCkgd2luIDU4NDAgPG1zcyAxNDYwLHNhY2tPSyx0aW1lc3RhbXAgNDQ5
MTAxMCAwLG5vcCx3c2NhbGUgNz4gKERGKSAodHRsIDY0LCBpZCAyNjQ1MSwgbGVuIDYwKQoJCQkg
NDUwMCAwMDNjIDY3NTMgNDAwMCA0MDA2IDc4MzkgMGE2NiAyMzRjCgkJCSAwYTY2IDIzMTggOTRi
MyAwZGEyIDNmNzUgZTA1MSAwMDAwIDAwMDAKCQkJIGEwMDIgMTZkMCA4YzlmIDAwMDAgMDIwNCAw
NWI0IDA0MDIgMDgwYQoJCQkgMDA0NCA4NzAyIDAwMDAgMDAwMCAwMTAzIDAzMDcKMjE6MDA6MDQu
NDg5ODU5IDEwLjEwMi4zNS43Ni4zODA2NyA+IDEwLjEwMi4zNS4yNC4zNDkwOiBTIFtiYWQgdGNw
IGNrc3VtIGZkZmYhXSAxMDY0Njg5NzQ1OjEwNjQ2ODk3NDUoMCkgd2luIDU4NDAgPG1zcyAxNDYw
LHNhY2tPSyx0aW1lc3RhbXAgNDQ5MTc2MCAwLG5vcCx3c2NhbGUgNz4gKERGKSAodHRsIDY0LCBp
ZCAyNjQ1MiwgbGVuIDYwKQoJCQkgNDUwMCAwMDNjIDY3NTQgNDAwMCA0MDA2IDc4MzggMGE2NiAy
MzRjCgkJCSAwYTY2IDIzMTggOTRiMyAwZGEyIDNmNzUgZTA1MSAwMDAwIDAwMDAKCQkJIGEwMDIg
MTZkMCA4OWIxIDAwMDAgMDIwNCAwNWI0IDA0MDIgMDgwYQoJCQkgMDA0NCA4OWYwIDAwMDAgMDAw
MCAwMTAzIDAzMDcKMjE6MDA6MDYuNDg5NTU0IGFycCB3aG8taGFzIDEwLjEwMi4zNS4yNCB0ZWxs
IDEwLjEwMi4zNS43NgoJCQkgMDAwMSAwODAwIDA2MDQgMDAwMSAwMDBiIGNkM2EgNWJmYiAwYTY2
CgkJCSAyMzRjIDAwMDAgMDAwMCAwMDAwIDBhNjYgMjMxOCAwMDAwIDAwMDAKCQkJIDAwMDAgMDAw
MCAwMDAwIDAwMDAgMDAwMCAwMDAwIDAwMDAKMjE6MDA6MDYuNDg5NTk2IGFycCByZXBseSAxMC4x
MDIuMzUuMjQgaXMtYXQgMDo4MDpjODoxOjU2OjEzCgkJCSAwMDAxIDA4MDAgMDYwNCAwMDAyIDAw
ODAgYzgwMSA1NjEzIDBhNjYKCQkJIDIzMTggMDAwYiBjZDNhIDViZmIgMGE2NiAyMzRjCgo0IHBh
Y2tldHMgcmVjZWl2ZWQgYnkgZmlsdGVyCjAgcGFja2V0cyBkcm9wcGVkIGJ5IGtlcm5lbAo=
------=_Part_7158_9973493.1193414587575
Content-Type: application/octet-stream; name=ethreal_dump.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f88w44yg
Content-Disposition: attachment; filename=ethreal_dump.pcap

1MOyoQIABAAAAAAAAAAAAGAAAAABAAAAxAciR75BBgBKAAAASgAAAACAyAFWEwALzTpb+wgARQAA
PGdTQABABng5CmYjTApmIxiUsw2iP3XgUQAAAACgAhbQjJ8AAAIEBbQEAggKAESHAgAAAAABAwMH
xwciR5c9BgBKAAAASgAAAACAyAFWEwALzTpb+wgARQAAPGdUQABABng4CmYjTApmIxiUsw2iP3Xg
UQAAAACgAhbQibEAAAIEBbQEAggKAESJ8AAAAAABAwMHyQciR3s8BgAqAAAAKgAAAACAyAFWEwAL
zTpb+wgGAAEIAAYEAAEAC806W/sKZiNMAAAAAAAACmYjGMkHIkf/PAYAPAAAADwAAAAAC806W/sA
gMgBVhMIBgABCAAGBAACAIDIAVYTCmYjGAALzTpb+wpmI0wAAAAAAAAAAAAAAAAAAAAAAAA=
------=_Part_7158_9973493.1193414587575--
