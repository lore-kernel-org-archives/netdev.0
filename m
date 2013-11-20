From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: RE: [PATCH] rds: Error on offset mismatch if not loopback
Date: Wed, 20 Nov 2013 10:09:39 -0800 (PST)
Message-ID: <25bef391-380b-486a-b06f-8be210e8abb7@default>
References: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
 <20120922.152524.1294103117346567757.davem@davemloft.net>
 <CAKA=qzac9=UhLF_Z4FnnH+sR7xvkDux4oayC6dPYe=hMLsDxRg@mail.gmail.com>
 <CAKA=qzYpd7Wo9XdU16TEhnbm5dPJjOZMhAY1jA7N+YFBWz5pzw@mail.gmail.com>
 <23964ca1-e7cb-41c3-9da2-5bc1b2b0c014@default>
 <CAKA=qzbK1YX5OrVQbwM=1xM6Si=GKv0UDofULkOC7RNo08zZPw@mail.gmail.com>
 <52841F95.7040204@redhat.com> <41aa904c-6707-4c74-ae72-96e401c68e13@default>
 <528587D0.5060105@redhat.com> <8744a6a4-d7a8-4e6f-8934-48a4fd4da0ce@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, jjolly@suse.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Honggang LI <honli@redhat.com>, Josh Hunt <joshhunt00@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8744a6a4-d7a8-4e6f-8934-48a4fd4da0ce@default>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: Venkat Venkatsubra 
Sent: Tuesday, November 19, 2013 5:33 PM
To: Honggang LI; Josh Hunt
Cc: David Miller; jjolly@suse.com; LKML; netdev@vger.kernel.org
Subject: RE: [PATCH] rds: Error on offset mismatch if not loopback

We now have lot more information than we did before.
When sending a "congestion update" in rds_ib_xmit() we are now returning an incorrect number as bytes sent:

        BUG_ON(off % RDS_FRAG_SIZE);
        BUG_ON(hdr_off != 0 && hdr_off != sizeof(struct rds_header));

        /* Do not send cong updates to IB loopback */
        if (conn->c_loopback
            && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
                rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
                scat = &rm->data.op_sg[sg];
                ret = sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
                ret = min_t(int, ret, scat->length - conn->c_xmit_data_off);
                return ret;
        }

It returns min(8240, 4096-0) i.e. 4096 bytes.
The caller rds_send_xmit() is made to think a partial message (4096 out of 8240) was sent.
It calls rds_ib_xmit() again with a data offset "off" of 4096-48 (rds header) (=4048 bytes). And we hit the BUG_ON.

The reason I didn't hit the panic on my test on Oracle UEK2 which is based on 2.6.39 kernel is it had it like this:
        BUG_ON(off % RDS_FRAG_SIZE);
        BUG_ON(hdr_off != 0 && hdr_off != sizeof(struct rds_header));

        /* Do not send cong updates to IB loopback */
        if (conn->c_loopback
            && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
                rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
                return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
        }
(So it wasn't 100% 2.6.39 ;-). )
It returned 8240 bytes. The caller rds_send_xmit decides the full message was sent (48 byte header + 4096 data + 4096 data).
And it worked.

Then I found this info on the change that was done upstream which now causes the panic:
http://marc.info/?l=linux-netdev&m=129908332903057
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6094628bfd94323fc1cea05ec2c6affd98c18f7f 

Will investigate more into which problem the above change addressed.

Venkat
--

Looks like the fix pointed to by the above link is for a panic on a PPC system with a PAGE_SIZE of 64Kbytes.
I think the sequence it was going through before that fix was:
/* Do not send cong updates to IB loopback */
        if (conn->c_loopback
            && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
                rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
                return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
        }
rds_ib_xmit returns 8240
rds_send_xmit : c_xmit_data_off = 0 + 8240 - 48 (rds header the first time) = 8196
                c_xmit_data_off < 65536 (sg->length)
                calls rds_ib_xmit again
rds_ib_xmit returns 8240
rds_send_xmit: c_xmit_data_off = 8192+8240 = 16432 and calls rds_ib_xmit
rds_ib_xmit : returns 8240
rds_send_xmit: c_xmit_data_off 24672 and calls rds_ib_xmit
...
...
and so on till
rds_send_xmit: c_xmit_data_off 57632 and calls rds_ib_xmit
rds_ib_xmit: returns 8240

On the last iteration it hits the below BUG_ON in rds_send_xmit.
while (ret) {
    tmp = min_t(int, ret, sg->length -
                         conn->c_xmit_data_off);
[tmp = 7904]
    conn->c_xmit_data_off += tmp;
[c_xmit_data_off = 65536]
    ret -= tmp;
[ret = 8240-7904 = 336]
    if (conn->c_xmit_data_off == sg->length) {
         conn->c_xmit_data_off = 0;
         sg++;
         conn->c_xmit_sg++;
         BUG_ON(ret != 0 &&
             conn->c_xmit_sg == rm->data.op_nents);
    }
}

Since the congestion update over loopback is not actually transmitted as a message,
the multiple iterations we see in the case of ppc is unnecessary.
All that rds_ib_xmit needs to do is return a number of bytes that will tell the caller that
we are done with this message.
  
This might fix the original problem without introducing the current panic:
/* Do not send cong updates to IB loopback */
        if (conn->c_loopback
            && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
                rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
                scat = &rm->data.op_sg[sg];
                ret = max_t(int, RDS_CONG_MAP_BYTES, scat->length);
                return ret + sizeof(struct rds_header);
        }
It will return 8240 when PAGE_SIZE is 4k and 64k+48 in case of ppc when scat->length is 64k and
be done with one iteration of rds_send_xmit/rds_ib_xmit loop.

Venkat
