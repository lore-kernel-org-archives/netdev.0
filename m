From: "Gaurav Aggarwal" <grv.aggarwal@gmail.com>
Subject: Bad TCP checksum error
Date: Fri, 26 Oct 2007 13:11:54 +0530
Message-ID: <1a41e0840710260041u4ebeb1e3h521e740a78f7e0bf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5242_32619055.1193384514086"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	davidsen@tmr.com, "Gaurav Aggarwal" <grv.aggarwal@gmail.com>
To: linux-net-owner@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_5242_32619055.1193384514086
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I wrote a program where I am using the nfnetlink and netfilter_queue
model to capture the packet. After that I just change the destination
address of the packet and insert it back into the ip stack. But after
inserting the packet I am getting a bad TCP checksum error. Even I am
getting the same error for IP header checksum. Attached is the source
code and tcpdump on host machine.

/* Source Code */
/* Compile with gcc -lnfnetlink -lnetfilter_queue  */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <linux/netfilter.h>		/* for NF_ACCEPT */
#include <arpa/inet.h>

#include <libnetfilter_queue/libnetfilter_queue.h>

#define  BUFSIZE  2048

struct in_addr foreign;
struct in_addr local;

struct queued_pckt {
	char *payload;
	int payload_len;
};

struct pseudohdr
{
	unsigned long ip_src ;
	unsigned long ip_dst ;
	unsigned char reserve ;
	unsigned char type ;
	unsigned short length;
} ;

unsigned short checksum(unsigned short *addr, unsigned int count) {
	/* Compute Internet Checksum for "count" bytes beginning at location "addr".
 	 * Algorithm is simple, using a 32-bit accumulator (sum),
	 * we add sequential 16-bit words to it, and at the end, fold back
	 * all the carry bits from the top 16 bits into the lower 16 bits.
 	*/
       register long sum = 0;
       unsigned short result;

        while (count > 1)  {
           /*  This is the inner loop */
               sum += * addr++;
               count -= 2;
       }
           /*  Add left-over byte, if any */
       if (count == 1)
       {
       		result = 0;	//make sure top half is zero
       		* (unsigned char *) (&result) = *(unsigned char *)addr;
       		sum += result;
	}
	
        /*
	 * Add back carry outs from top 16 bits to low 16 bits.
         * Fold 32-bit sum to 16 bits
	*/

       sum = (sum >> 16) + (sum & 0xffff); 	/* add high-16 to low-16 */
       sum += (sum >> 16);			/* add carry */

       result = ~sum;			/* ones-complement, then truncate to 16 bits */	
       return (result);
}


unsigned short get_tcp_chksum (struct tcphdr *orig_tcphdr, struct
iphdr *orig_iphdr )
{
	struct pseudohdr pseudoh ;

	unsigned int total_len = ntohs(orig_iphdr->tot_len);
	int tcpopt_len = (orig_tcphdr->doff * 4) - 20;
	int tcpdata_len = total_len - (orig_tcphdr->doff * 4) - (orig_iphdr->ihl * 4);

	pseudoh.ip_src = orig_iphdr->saddr ;
	pseudoh.ip_dst = orig_iphdr->daddr ;
	pseudoh.reserve = 0 ; 	
	pseudoh.type = orig_iphdr->protocol ;
	pseudoh.length = htons (sizeof (struct tcphdr) + tcpopt_len + tcpdata_len) ;

	int totaltcp_len = sizeof(struct pseudohdr) + sizeof(struct tcphdr) +
tcpopt_len + tcpdata_len;

	unsigned short *tcp = (unsigned short *)malloc (totaltcp_len);

	memcpy ((unsigned char *)tcp, &pseudoh, sizeof(struct pseudohdr));
	memcpy ((unsigned char *)tcp + sizeof(struct pseudohdr), (unsigned
char *)orig_tcphdr, sizeof(struct tcphdr));
	if (tcpopt_len > 0)
		memcpy ((unsigned char *)tcp + sizeof(struct pseudohdr) +
sizeof(struct tcphdr), (unsigned char *)orig_iphdr + (orig_iphdr->ihl
* 4) + sizeof(struct tcphdr), tcpopt_len);
	
	if (tcpdata_len > 0)
		memcpy ((unsigned char *)tcp + sizeof(struct pseudohdr) +
sizeof(struct tcphdr) + tcpopt_len, (unsigned char *)orig_tcphdr +
(orig_tcphdr->doff * 4), tcpdata_len);

#if 0
	printf("pseudo length: %d\n",pseudoh.length);
        printf("tcp hdr length: %d\n",orig_tcphdr->doff*4);
        printf("tcp hdr struct length: %d\n",sizeof(struct tcphdr));
        printf("tcphdr->doff = %d, tcp opt length:
%d\n",orig_tcphdr->doff,tcpopt_len);
        printf("tcp total+psuedo length: %d\n",totaltcp_len);

        fflush(stdout);

        printf("tcp data len: %d, data start %u\n",
tcpdata_len,orig_tcphdr + (orig_tcphdr->doff*4));
#endif
	
	return (checksum (tcp, totaltcp_len)) ;
}

static void filter(
	unsigned char *packet, unsigned int payload_len)
{
	struct iphdr *iphdr;
	struct tcphdr *tcphdr;

	printf ("in filter function\n");

	iphdr = (struct iphdr *)packet;
	/* check need some datas */
	if (payload_len < sizeof(struct iphdr) + sizeof(struct tcphdr)) {
		return;
	}
	/* check IP version */
	if (iphdr->protocol == IPPROTO_TCP)
	{
		tcphdr = (struct tcphdr *)(((u_int32_t *)packet) + 4 * iphdr->ihl);

		if (iphdr->daddr == foreign.s_addr)
		{
			printf ("packet DEST addr = %s\n",inet_ntoa(foreign));
			fprintf (stderr, "changing pkt's DEST addr from FOREIGN to LOCAL\n");
			iphdr->daddr = local.s_addr;
			tcphdr->check = 0 ; // checksum will be calculated later
			iphdr->check = checksum(
				(unsigned short *)iphdr,
				sizeof(struct iphdr));
			tcphdr->check = get_tcp_chksum(
				tcphdr,
				iphdr);
		}
	}

}

static int cb(struct nfq_q_handle *qh, struct nfgenmsg *nfmsg,
	      struct nfq_data *nfa, void *data)
{
	int id = 0;
	struct nfqnl_msg_packet_hdr *ph;
	struct queued_pckt q_pckt;
	u_int32_t mark,ifi;
	int ret;
	char *payload;
	
	printf("entering callback\n");
	ph = nfq_get_msg_packet_hdr(nfa);
	if (ph){
		id = ntohl(ph->packet_id);
		printf("hw_protocol=0x%04x hook=%u id=%u ",
			ntohs(ph->hw_protocol), ph->hook, id);
	}
	
	mark = nfq_get_nfmark(nfa);
	if (mark)
		printf("mark=%u ", mark);

	ifi = nfq_get_indev(nfa);
	if (ifi)
		printf("indev=%u ", ifi);

	ifi = nfq_get_outdev(nfa);
	if (ifi)
		printf("outdev=%u ", ifi);

	q_pckt.payload_len = nfq_get_payload(nfa, &(q_pckt.payload));
	if (q_pckt.payload_len >= 0)
	{
		printf("payload_len=%d ", q_pckt.payload_len);
		fputc('\n', stdout);
		filter((unsigned char *)q_pckt.payload, q_pckt.payload_len);
	}
	
	printf("setting verdict of packet id %d\n",id);
	return nfq_set_verdict(qh, id, NF_ACCEPT, q_pckt.payload_len, q_pckt.payload);
}

int main(int argc, char **argv)
{
	struct nfq_handle *h;
	struct nfq_q_handle *qh;
	struct nfnl_handle *nh;
	int fd;
	int rv;
	unsigned char buf[BUFSIZE];

	if (argc == 1)
	{
		inet_aton("10.102.130.222", &(foreign));
		inet_aton("10.102.130.105", &(local));
	} else if (argc == 3)
	{
		inet_aton(argv[1], &(foreign));
		inet_aton(argv[2], &(local));
	}
	else
	{
		printf("Usage: argv[0] [foreign_addr local_addr]\n");
		return 0;
	}

	printf("opening library handle\n");
	h = nfq_open();
	if (!h) {
		fprintf(stderr, "error during nfq_open()\n");
		return 0;
	}

	printf("unbinding existing nf_queue handler for AF_INET (if any)\n");
	if (nfq_unbind_pf(h, AF_INET) < 0) {
		fprintf(stderr, "error during nfq_unbind_pf()\n");
		exit(1);
	}

	printf("binding nfnetlink_queue as nf_queue handler for AF_INET\n");
	if (nfq_bind_pf(h, AF_INET) < 0) {
		fprintf(stderr, "error during nfq_bind_pf()\n");
		exit(1);
	}

	printf("binding this socket to queue '0'\n");
	qh = nfq_create_queue(h,  0, &cb, NULL);
	if (!qh) {
		fprintf(stderr, "error during nfq_create_queue()\n");
		exit(1);
	}

	printf("setting copy_packet mode\n");
	if (nfq_set_mode(qh, NFQNL_COPY_PACKET, BUFSIZE) < 0) {
		fprintf(stderr, "can't set packet_copy mode\n");
		exit(1);
	}

	nh = nfq_nfnlh(h);
	fd = nfnl_fd(nh);

	while ((rv = recv(fd, buf, BUFSIZE, 0)) && rv >= 0) {
		printf("pkt received\n");
		nfq_handle_packet(h, buf, rv);
		printf("pkt handled\n");
	}

	printf("unbinding from queue 0\n");
	nfq_destroy_queue(qh);

	printf("closing library handle\n");
	nfq_close(h);

	exit(0);
}
/* end - Source Code */

/* TCP dump */
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
12:59:36.706161 IP (tos 0x0, ttl  64, id 61974, offset 0, flags [DF],
proto: TCP (6), length: 60, bad cksum 75 (->8e24)!) 10.102.35.76.36898
> 10.102.130.105.colubris: S, cksum 0xc6d5 (incorrect (-> 0xc74a),
366446207:366446207(0) win 5840 <mss 1460,sackOK,timestamp 14775401
0,nop,wscale 6>
	0x0000:  0012 010a 5f4c 000b cd3a 5bfb 0800 4500
	0x0010:  003c f216 4000 4006 0075 0a66 234c 0a66
	0x0020:  8269 9022 0da2 15d7 867f 0000 0000 a002
	0x0030:  16d0 c6d5 0000 0204 05b4 0402 080a 00e1
	0x0040:  7469 0000 0000 0103 0306
12:59:39.708619 IP (tos 0x0, ttl  64, id 61975, offset 0, flags [DF],
proto: TCP (6), length: 60, bad cksum 75 (->8e23)!) 10.102.35.76.36898
> 10.102.130.105.colubris: S, cksum 0xc3e7 (incorrect (-> 0xc45c),
366446207:366446207(0) win 5840 <mss 1460,sackOK,timestamp 14776151
0,nop,wscale 6>
	0x0000:  0012 010a 5f4c 000b cd3a 5bfb 0800 4500
	0x0010:  003c f217 4000 4006 0075 0a66 234c 0a66
	0x0020:  8269 9022 0da2 15d7 867f 0000 0000 a002
	0x0030:  16d0 c3e7 0000 0204 05b4 0402 080a 00e1
	0x0040:  7757 0000 0000 0103 0306

2 packets captured
4 packets received by filter
0 packets dropped by kernel
/* End - TCP dump */

Attached is the dump for ethreal also.

-- 
Regards,
Gaurav Aggarwal

------=_Part_5242_32619055.1193384514086
Content-Type: application/octet-stream; name=nfq_test.c
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f88e7vw0
Content-Disposition: attachment; filename=nfq_test.c

LyogQ29tcGlsZSB3aXRoIGdjYyAtbG5mbmV0bGluayAtbG5ldGZpbHRlcl9xdWV1ZSAgKi8KI2lu
Y2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgoj
aW5jbHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRlIDxuZXRpbmV0L2luLmg+CiNpbmNsdWRlIDxuZXRp
bmV0L2lwLmg+CiNpbmNsdWRlIDxuZXRpbmV0L3RjcC5oPgojaW5jbHVkZSA8bGludXgvbmV0Zmls
dGVyLmg+CQkvKiBmb3IgTkZfQUNDRVBUICovCiNpbmNsdWRlIDxhcnBhL2luZXQuaD4KCiNpbmNs
dWRlIDxsaWJuZXRmaWx0ZXJfcXVldWUvbGlibmV0ZmlsdGVyX3F1ZXVlLmg+CgojZGVmaW5lICBC
VUZTSVpFICAyMDQ4CgpzdHJ1Y3QgaW5fYWRkciBmb3JlaWduOwpzdHJ1Y3QgaW5fYWRkciBsb2Nh
bDsKCnN0cnVjdCBxdWV1ZWRfcGNrdCB7CgljaGFyICpwYXlsb2FkOwoJaW50IHBheWxvYWRfbGVu
Owp9OwoKc3RydWN0IHBzZXVkb2hkcgp7Cgl1bnNpZ25lZCBsb25nIGlwX3NyYyA7Cgl1bnNpZ25l
ZCBsb25nIGlwX2RzdCA7Cgl1bnNpZ25lZCBjaGFyIHJlc2VydmUgOwoJdW5zaWduZWQgY2hhciB0
eXBlIDsKCXVuc2lnbmVkIHNob3J0IGxlbmd0aDsKfSA7Cgp1bnNpZ25lZCBzaG9ydCBjaGVja3N1
bSh1bnNpZ25lZCBzaG9ydCAqYWRkciwgdW5zaWduZWQgaW50IGNvdW50KSB7CgkvKiBDb21wdXRl
IEludGVybmV0IENoZWNrc3VtIGZvciAiY291bnQiIGJ5dGVzIGJlZ2lubmluZyBhdCBsb2NhdGlv
biAiYWRkciIuCiAJICogQWxnb3JpdGhtIGlzIHNpbXBsZSwgdXNpbmcgYSAzMi1iaXQgYWNjdW11
bGF0b3IgKHN1bSksCgkgKiB3ZSBhZGQgc2VxdWVudGlhbCAxNi1iaXQgd29yZHMgdG8gaXQsIGFu
ZCBhdCB0aGUgZW5kLCBmb2xkIGJhY2sKCSAqIGFsbCB0aGUgY2FycnkgYml0cyBmcm9tIHRoZSB0
b3AgMTYgYml0cyBpbnRvIHRoZSBsb3dlciAxNiBiaXRzLgogCSovCiAgICAgICByZWdpc3RlciBs
b25nIHN1bSA9IDA7CiAgICAgICB1bnNpZ25lZCBzaG9ydCByZXN1bHQ7CgogICAgICAgIHdoaWxl
IChjb3VudCA+IDEpICB7CiAgICAgICAgICAgLyogIFRoaXMgaXMgdGhlIGlubmVyIGxvb3AgKi8K
ICAgICAgICAgICAgICAgc3VtICs9ICogYWRkcisrOwogICAgICAgICAgICAgICBjb3VudCAtPSAy
OwogICAgICAgfQogICAgICAgICAgIC8qICBBZGQgbGVmdC1vdmVyIGJ5dGUsIGlmIGFueSAqLwog
ICAgICAgaWYgKGNvdW50ID09IDEpCiAgICAgICB7CiAgICAgICAJCXJlc3VsdCA9IDA7CS8vbWFr
ZSBzdXJlIHRvcCBoYWxmIGlzIHplcm8KICAgICAgIAkJKiAodW5zaWduZWQgY2hhciAqKSAoJnJl
c3VsdCkgPSAqKHVuc2lnbmVkIGNoYXIgKilhZGRyOwogICAgICAgCQlzdW0gKz0gcmVzdWx0OwoJ
fQoJCiAgICAgICAgLyoKCSAqIEFkZCBiYWNrIGNhcnJ5IG91dHMgZnJvbSB0b3AgMTYgYml0cyB0
byBsb3cgMTYgYml0cy4KICAgICAgICAgKiBGb2xkIDMyLWJpdCBzdW0gdG8gMTYgYml0cyAKCSov
CiAgICAgICAKICAgICAgIHN1bSA9IChzdW0gPj4gMTYpICsgKHN1bSAmIDB4ZmZmZik7IAkvKiBh
ZGQgaGlnaC0xNiB0byBsb3ctMTYgKi8KICAgICAgIHN1bSArPSAoc3VtID4+IDE2KTsJCQkvKiBh
ZGQgY2FycnkgKi8gCgogICAgICAgcmVzdWx0ID0gfnN1bTsJCQkvKiBvbmVzLWNvbXBsZW1lbnQs
IHRoZW4gdHJ1bmNhdGUgdG8gMTYgYml0cyAqLwkKICAgICAgIHJldHVybiAocmVzdWx0KTsKfQoK
CnVuc2lnbmVkIHNob3J0IGdldF90Y3BfY2hrc3VtIChzdHJ1Y3QgdGNwaGRyICpvcmlnX3RjcGhk
ciwgc3RydWN0IGlwaGRyICpvcmlnX2lwaGRyICkKewoJc3RydWN0IHBzZXVkb2hkciBwc2V1ZG9o
IDsKCgl1bnNpZ25lZCBpbnQgdG90YWxfbGVuID0gbnRvaHMob3JpZ19pcGhkci0+dG90X2xlbik7
CglpbnQgdGNwb3B0X2xlbiA9IChvcmlnX3RjcGhkci0+ZG9mZiAqIDQpIC0gMjA7CglpbnQgdGNw
ZGF0YV9sZW4gPSB0b3RhbF9sZW4gLSAob3JpZ190Y3BoZHItPmRvZmYgKiA0KSAtIChvcmlnX2lw
aGRyLT5paGwgKiA0KTsgCgoJcHNldWRvaC5pcF9zcmMgPSBvcmlnX2lwaGRyLT5zYWRkciA7Cglw
c2V1ZG9oLmlwX2RzdCA9IG9yaWdfaXBoZHItPmRhZGRyIDsKCXBzZXVkb2gucmVzZXJ2ZSA9IDAg
OyAJCglwc2V1ZG9oLnR5cGUgPSBvcmlnX2lwaGRyLT5wcm90b2NvbCA7ICAKCXBzZXVkb2gubGVu
Z3RoID0gaHRvbnMgKHNpemVvZiAoc3RydWN0IHRjcGhkcikgKyB0Y3BvcHRfbGVuICsgdGNwZGF0
YV9sZW4pIDsKCglpbnQgdG90YWx0Y3BfbGVuID0gc2l6ZW9mKHN0cnVjdCBwc2V1ZG9oZHIpICsg
c2l6ZW9mKHN0cnVjdCB0Y3BoZHIpICsgdGNwb3B0X2xlbiArIHRjcGRhdGFfbGVuOyAKCgl1bnNp
Z25lZCBzaG9ydCAqdGNwID0gKHVuc2lnbmVkIHNob3J0ICopbWFsbG9jICh0b3RhbHRjcF9sZW4p
OwoKCW1lbWNweSAoKHVuc2lnbmVkIGNoYXIgKil0Y3AsICZwc2V1ZG9oLCBzaXplb2Yoc3RydWN0
IHBzZXVkb2hkcikpOwoJbWVtY3B5ICgodW5zaWduZWQgY2hhciAqKXRjcCArIHNpemVvZihzdHJ1
Y3QgcHNldWRvaGRyKSwgKHVuc2lnbmVkIGNoYXIgKilvcmlnX3RjcGhkciwgc2l6ZW9mKHN0cnVj
dCB0Y3BoZHIpKTsKCWlmICh0Y3BvcHRfbGVuID4gMCkKCQltZW1jcHkgKCh1bnNpZ25lZCBjaGFy
ICopdGNwICsgc2l6ZW9mKHN0cnVjdCBwc2V1ZG9oZHIpICsgc2l6ZW9mKHN0cnVjdCB0Y3BoZHIp
LCAodW5zaWduZWQgY2hhciAqKW9yaWdfaXBoZHIgKyAob3JpZ19pcGhkci0+aWhsICogNCkgKyBz
aXplb2Yoc3RydWN0IHRjcGhkciksIHRjcG9wdF9sZW4pOwoJCglpZiAodGNwZGF0YV9sZW4gPiAw
KQoJCW1lbWNweSAoKHVuc2lnbmVkIGNoYXIgKil0Y3AgKyBzaXplb2Yoc3RydWN0IHBzZXVkb2hk
cikgKyBzaXplb2Yoc3RydWN0IHRjcGhkcikgKyB0Y3BvcHRfbGVuLCAodW5zaWduZWQgY2hhciAq
KW9yaWdfdGNwaGRyICsgKG9yaWdfdGNwaGRyLT5kb2ZmICogNCksIHRjcGRhdGFfbGVuKTsKCiNp
ZiAwCglwcmludGYoInBzZXVkbyBsZW5ndGg6ICVkXG4iLHBzZXVkb2gubGVuZ3RoKTsKICAgICAg
ICBwcmludGYoInRjcCBoZHIgbGVuZ3RoOiAlZFxuIixvcmlnX3RjcGhkci0+ZG9mZio0KTsKICAg
ICAgICBwcmludGYoInRjcCBoZHIgc3RydWN0IGxlbmd0aDogJWRcbiIsc2l6ZW9mKHN0cnVjdCB0
Y3BoZHIpKTsKICAgICAgICBwcmludGYoInRjcGhkci0+ZG9mZiA9ICVkLCB0Y3Agb3B0IGxlbmd0
aDogJWRcbiIsb3JpZ190Y3BoZHItPmRvZmYsdGNwb3B0X2xlbik7CiAgICAgICAgcHJpbnRmKCJ0
Y3AgdG90YWwrcHN1ZWRvIGxlbmd0aDogJWRcbiIsdG90YWx0Y3BfbGVuKTsKCiAgICAgICAgZmZs
dXNoKHN0ZG91dCk7CgogICAgICAgIHByaW50ZigidGNwIGRhdGEgbGVuOiAlZCwgZGF0YSBzdGFy
dCAldVxuIiwgdGNwZGF0YV9sZW4sb3JpZ190Y3BoZHIgKyAob3JpZ190Y3BoZHItPmRvZmYqNCkp
OwojZW5kaWYKCQoJcmV0dXJuIChjaGVja3N1bSAodGNwLCB0b3RhbHRjcF9sZW4pKSA7Cn0KCnN0
YXRpYyB2b2lkIGZpbHRlcigKCXVuc2lnbmVkIGNoYXIgKnBhY2tldCwgdW5zaWduZWQgaW50IHBh
eWxvYWRfbGVuKQp7CglzdHJ1Y3QgaXBoZHIgKmlwaGRyOwoJc3RydWN0IHRjcGhkciAqdGNwaGRy
OwoKCXByaW50ZiAoImluIGZpbHRlciBmdW5jdGlvblxuIik7CgoJaXBoZHIgPSAoc3RydWN0IGlw
aGRyICopcGFja2V0OwoJLyogY2hlY2sgbmVlZCBzb21lIGRhdGFzICovCglpZiAocGF5bG9hZF9s
ZW4gPCBzaXplb2Yoc3RydWN0IGlwaGRyKSArIHNpemVvZihzdHJ1Y3QgdGNwaGRyKSkgewoJCXJl
dHVybjsKCX0KCS8qIGNoZWNrIElQIHZlcnNpb24gKi8KCWlmIChpcGhkci0+cHJvdG9jb2wgPT0g
SVBQUk9UT19UQ1ApCgl7CgkJdGNwaGRyID0gKHN0cnVjdCB0Y3BoZHIgKikoKCh1X2ludDMyX3Qg
KilwYWNrZXQpICsgNCAqIGlwaGRyLT5paGwpOwoKCQlpZiAoaXBoZHItPmRhZGRyID09IGZvcmVp
Z24uc19hZGRyKQoJCXsKCQkJcHJpbnRmICgicGFja2V0IERFU1QgYWRkciA9ICVzXG4iLGluZXRf
bnRvYShmb3JlaWduKSk7CgkJCWZwcmludGYgKHN0ZGVyciwgImNoYW5naW5nIHBrdCdzIERFU1Qg
YWRkciBmcm9tIEZPUkVJR04gdG8gTE9DQUxcbiIpOwoJCQlpcGhkci0+ZGFkZHIgPSBsb2NhbC5z
X2FkZHI7CgkJCXRjcGhkci0+Y2hlY2sgPSAwIDsgLy8gY2hlY2tzdW0gd2lsbCBiZSBjYWxjdWxh
dGVkIGxhdGVyCgkJCWlwaGRyLT5jaGVjayA9IGNoZWNrc3VtKAoJCQkJKHVuc2lnbmVkIHNob3J0
ICopaXBoZHIsCgkJCQlzaXplb2Yoc3RydWN0IGlwaGRyKSk7CgkJCXRjcGhkci0+Y2hlY2sgPSBn
ZXRfdGNwX2Noa3N1bSgKCQkJCXRjcGhkciwKCQkJCWlwaGRyKTsKCQl9Cgl9Cgp9CgpzdGF0aWMg
aW50IGNiKHN0cnVjdCBuZnFfcV9oYW5kbGUgKnFoLCBzdHJ1Y3QgbmZnZW5tc2cgKm5mbXNnLAoJ
ICAgICAgc3RydWN0IG5mcV9kYXRhICpuZmEsIHZvaWQgKmRhdGEpCnsKCWludCBpZCA9IDA7Cglz
dHJ1Y3QgbmZxbmxfbXNnX3BhY2tldF9oZHIgKnBoOwoJc3RydWN0IHF1ZXVlZF9wY2t0IHFfcGNr
dDsKCXVfaW50MzJfdCBtYXJrLGlmaTsgCglpbnQgcmV0OwoJY2hhciAqcGF5bG9hZDsKCQoJcHJp
bnRmKCJlbnRlcmluZyBjYWxsYmFja1xuIik7CglwaCA9IG5mcV9nZXRfbXNnX3BhY2tldF9oZHIo
bmZhKTsKCWlmIChwaCl7CgkJaWQgPSBudG9obChwaC0+cGFja2V0X2lkKTsKCQlwcmludGYoImh3
X3Byb3RvY29sPTB4JTA0eCBob29rPSV1IGlkPSV1ICIsCgkJCW50b2hzKHBoLT5od19wcm90b2Nv
bCksIHBoLT5ob29rLCBpZCk7Cgl9CgkKCW1hcmsgPSBuZnFfZ2V0X25mbWFyayhuZmEpOwoJaWYg
KG1hcmspCgkJcHJpbnRmKCJtYXJrPSV1ICIsIG1hcmspOwoKCWlmaSA9IG5mcV9nZXRfaW5kZXYo
bmZhKTsKCWlmIChpZmkpCgkJcHJpbnRmKCJpbmRldj0ldSAiLCBpZmkpOwoKCWlmaSA9IG5mcV9n
ZXRfb3V0ZGV2KG5mYSk7CglpZiAoaWZpKQoJCXByaW50Zigib3V0ZGV2PSV1ICIsIGlmaSk7CgoJ
cV9wY2t0LnBheWxvYWRfbGVuID0gbmZxX2dldF9wYXlsb2FkKG5mYSwgJihxX3Bja3QucGF5bG9h
ZCkpOwoJaWYgKHFfcGNrdC5wYXlsb2FkX2xlbiA+PSAwKQoJewoJCXByaW50ZigicGF5bG9hZF9s
ZW49JWQgIiwgcV9wY2t0LnBheWxvYWRfbGVuKTsKCQlmcHV0YygnXG4nLCBzdGRvdXQpOwoJCWZp
bHRlcigodW5zaWduZWQgY2hhciAqKXFfcGNrdC5wYXlsb2FkLCBxX3Bja3QucGF5bG9hZF9sZW4p
OwoJfQoJCglwcmludGYoInNldHRpbmcgdmVyZGljdCBvZiBwYWNrZXQgaWQgJWRcbiIsaWQpOwoJ
cmV0dXJuIG5mcV9zZXRfdmVyZGljdChxaCwgaWQsIE5GX0FDQ0VQVCwgcV9wY2t0LnBheWxvYWRf
bGVuLCBxX3Bja3QucGF5bG9hZCk7Cn0KCmludCBtYWluKGludCBhcmdjLCBjaGFyICoqYXJndikK
ewoJc3RydWN0IG5mcV9oYW5kbGUgKmg7CglzdHJ1Y3QgbmZxX3FfaGFuZGxlICpxaDsKCXN0cnVj
dCBuZm5sX2hhbmRsZSAqbmg7CglpbnQgZmQ7CglpbnQgcnY7Cgl1bnNpZ25lZCBjaGFyIGJ1ZltC
VUZTSVpFXTsKCglpZiAoYXJnYyA9PSAxKQoJewoJCWluZXRfYXRvbigiMTAuMTAyLjEzMC4yMjIi
LCAmKGZvcmVpZ24pKTsKCQlpbmV0X2F0b24oIjEwLjEwMi4xMzAuMTA1IiwgJihsb2NhbCkpOwoJ
fSBlbHNlIGlmIChhcmdjID09IDMpCgl7CgkJaW5ldF9hdG9uKGFyZ3ZbMV0sICYoZm9yZWlnbikp
OwoJCWluZXRfYXRvbihhcmd2WzJdLCAmKGxvY2FsKSk7Cgl9CgllbHNlCgl7CgkJcHJpbnRmKCJV
c2FnZTogYXJndlswXSBbZm9yZWlnbl9hZGRyIGxvY2FsX2FkZHJdXG4iKTsKCQlyZXR1cm4gMDsK
CX0KCglwcmludGYoIm9wZW5pbmcgbGlicmFyeSBoYW5kbGVcbiIpOwoJaCA9IG5mcV9vcGVuKCk7
CglpZiAoIWgpIHsKCQlmcHJpbnRmKHN0ZGVyciwgImVycm9yIGR1cmluZyBuZnFfb3BlbigpXG4i
KTsKCQlyZXR1cm4gMDsKCX0KCglwcmludGYoInVuYmluZGluZyBleGlzdGluZyBuZl9xdWV1ZSBo
YW5kbGVyIGZvciBBRl9JTkVUIChpZiBhbnkpXG4iKTsKCWlmIChuZnFfdW5iaW5kX3BmKGgsIEFG
X0lORVQpIDwgMCkgewoJCWZwcmludGYoc3RkZXJyLCAiZXJyb3IgZHVyaW5nIG5mcV91bmJpbmRf
cGYoKVxuIik7CgkJZXhpdCgxKTsKCX0KCglwcmludGYoImJpbmRpbmcgbmZuZXRsaW5rX3F1ZXVl
IGFzIG5mX3F1ZXVlIGhhbmRsZXIgZm9yIEFGX0lORVRcbiIpOwoJaWYgKG5mcV9iaW5kX3BmKGgs
IEFGX0lORVQpIDwgMCkgewoJCWZwcmludGYoc3RkZXJyLCAiZXJyb3IgZHVyaW5nIG5mcV9iaW5k
X3BmKClcbiIpOwoJCWV4aXQoMSk7Cgl9CgoJcHJpbnRmKCJiaW5kaW5nIHRoaXMgc29ja2V0IHRv
IHF1ZXVlICcwJ1xuIik7CglxaCA9IG5mcV9jcmVhdGVfcXVldWUoaCwgIDAsICZjYiwgTlVMTCk7
CglpZiAoIXFoKSB7CgkJZnByaW50ZihzdGRlcnIsICJlcnJvciBkdXJpbmcgbmZxX2NyZWF0ZV9x
dWV1ZSgpXG4iKTsKCQlleGl0KDEpOwoJfQoKCXByaW50Zigic2V0dGluZyBjb3B5X3BhY2tldCBt
b2RlXG4iKTsKCWlmIChuZnFfc2V0X21vZGUocWgsIE5GUU5MX0NPUFlfUEFDS0VULCBCVUZTSVpF
KSA8IDApIHsKCQlmcHJpbnRmKHN0ZGVyciwgImNhbid0IHNldCBwYWNrZXRfY29weSBtb2RlXG4i
KTsKCQlleGl0KDEpOwoJfQoKCW5oID0gbmZxX25mbmxoKGgpOwoJZmQgPSBuZm5sX2ZkKG5oKTsK
Cgl3aGlsZSAoKHJ2ID0gcmVjdihmZCwgYnVmLCBCVUZTSVpFLCAwKSkgJiYgcnYgPj0gMCkgewoJ
CXByaW50ZigicGt0IHJlY2VpdmVkXG4iKTsKCQluZnFfaGFuZGxlX3BhY2tldChoLCBidWYsIHJ2
KTsKCQlwcmludGYoInBrdCBoYW5kbGVkXG4iKTsKCX0KCglwcmludGYoInVuYmluZGluZyBmcm9t
IHF1ZXVlIDBcbiIpOwoJbmZxX2Rlc3Ryb3lfcXVldWUocWgpOwoKCXByaW50ZigiY2xvc2luZyBs
aWJyYXJ5IGhhbmRsZVxuIik7CgluZnFfY2xvc2UoaCk7CgoJZXhpdCgwKTsKfQo=
------=_Part_5242_32619055.1193384514086
Content-Type: application/octet-stream; name=dump.pcap
Content-Transfer-Encoding: base64
X-Attachment-Id: f_f88e9d5x
Content-Disposition: attachment; filename=dump.pcap

1MOyoQIABAAAAAAAAAAAAGAAAAABAAAA5JYhR9HACABKAAAASgAAAAASAQpfTAALzTpb+wgARQAA
PD4DQABABgB1CmYjTApmgmmQHw2iDnfFMwAAAACgAhbQCL4AAAIEBbQEAggKAOD7MAAAAAABAwMG
55YhR2q5CABKAAAASgAAAAASAQpfTAALzTpb+wgARQAAPD4EQABABgB1CmYjTApmgmmQHw2iDnfF
MwAAAACgAhbQBdAAAAIEBbQEAggKAOD+HgAAAAABAwMG
------=_Part_5242_32619055.1193384514086--
