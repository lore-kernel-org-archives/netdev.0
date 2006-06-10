From: "Vasantha Kumar Puttappa" <vasanthakumar@iitb.ac.in>
Subject: LIBIPQ: problem with Injecting encapsulated packet  (plz somebody
     )     reply)]
Date: Sat, 10 Jun 2006 21:33:23 +0530 (IST)
Message-ID: <1292.10.12.25.5.1149955403.squirrel@gpo.iitb.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.iitb.ac.in ([59.163.25.49]:17608 "HELO smtp1.iitb.ac.in")
	by vger.kernel.org with SMTP id S1751196AbWFJQD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 12:03:57 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
 I am posting this query again. plz somebody reply. Also I am new to
IPtables and LIBIPQ

 I am working on a application that involves encapsulatting the packets .
Suppose there are 3 machines A B C. Assume that machine A is sending some
some information to machine B. All I do is to capture packets(using
libipq) destined for machine B  on machine A and send it to machine C . I
encapuslate this captured packet in a new packet with(adding both IP/UDP
header, although UDP header is not really required, with destinatin
address as machine C IP).

The issue is that after the call to set_verdict function, instead of the
encapsulated packet, original packet is getting transmitted. I tried my
best to find the solution with no success. I am updating the checksum
correctly after adding new header.

Below is snippet of my code

**************

unsigned char *new_packet = NULL;
struct iphdr *new_iphdr;
struct iphdr *original_iphdr = (struct iphdr *)(m->payload);
int status;


new_packet = (unsigned char *) calloc(1,sizeof(struct iphdr) +
(m->data_len) + sizeof(struct udphdr));
new_iphdr = (struct iphdr *) calloc(1,sizeof(struct iphdr));




    /* extra Udp header */

    struct udphdr *new_udp;

    new_udp = (struct udphdr *) calloc(1,sizeof(struct udphdr));
    new_udp->source = htons(50000);
    new_udp->dest = htons(50000);
    new_udp->len =  original_iphdr->tot_len;
    new_udp->check = 0;

    /* udp*/


     /** New IP header **/
     new_iphdr->version = original_iphdr->version;
     new_iphdr->ihl = original_iphdr->ihl;
     new_iphdr->tos = original_iphdr->tos;
     new_iphdr->id  = original_iphdr->id;;
     new_iphdr->frag_off = original_iphdr->frag_off;
     new_iphdr->ttl = original_iphdr->ttl;
     new_iphdr->protocol = original_iphdr->protocol;
     new_iphdr->saddr= inet_addr("10.107.26.27");//original_iphdr->saddr;
     new_iphdr->daddr=inet_addr("10.12.25.7");//daddr.s_addr;

     new_iphdr->tot_len=htons(ntohs(original_iphdr->tot_len)+
(sizeof(struct iphdr))+ sizeof(struct udphdr));


     new_iphdr->check=0;
     new_iphdr->check=(((ip_sum_calc((unsigned short
*)new_iphdr,sizeof(struct iphdr)))));


     // Place the IP packet inside another IP packet
     memcpy(new_packet,new_iphdr,(unsigned int)sizeof(struct iphdr));

     memcpy(new_packet+sizeof(struct iphdr),new_udp,(unsigned
int)sizeof(struct udphdr));

     memcpy(new_packet+sizeof(struct iphdr)+sizeof(struct
udphdr),m->payload,m->data_len);



     size_t length = ntohs(new_iphdr->tot_len);;

     status =
ipq_set_verdict(handle,m->packet_id,NF_ACCEPT,length,(unsigned char
*) new_packet);


     if(status < 0)
       {
	 printf("\n Packet Modification failed \n");
	 die();
       }


     printf("\n  Packet Transmitted Successfull \n");



*********checksum function**********
unsigned short ip_sum_calc(unsigned short *addr,int len)
{

  int nleft = len;
  int sum = 0;
  unsigned short *w = addr;
  unsigned short answer = 0;

  printf(" \nsize %d", sizeof(sum));

  while (nleft > 1)
    {
      sum += *w++;
      nleft -= 2;
    }


  if (nleft == 1)
    {
      *(unsigned char *)(&answer) = *(unsigned char *) w;
      sum += answer;
    }
  sum = (sum >> 16) + (sum & 0xffff);
  sum += (sum >> 16);
  answer = ~sum;


    return answer;

}











