From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 79681] New: Out of order data packets triggered by ARP
 cache state update
Date: Wed, 9 Jul 2014 02:48:21 -0700
Message-ID: <20140709024821.6eb07566@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59133 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756501AbaGIQyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 12:54:38 -0400
Received: by mail-wi0-f178.google.com with SMTP id f8so2625317wiw.5
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 09:54:37 -0700 (PDT)
Received: from samsung-9 (243-249.80-90.static-ip.oleane.fr. [90.80.249.243])
        by mx.google.com with ESMTPSA id cz4sm21273078wib.23.2014.07.09.09.54.35
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 09:54:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 8 Jul 2014 13:08:51 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 79681] New: Out of order data packets triggered by ARP cache state update


https://bugzilla.kernel.org/show_bug.cgi?id=79681

            Bug ID: 79681
           Summary: Out of order data packets triggered by ARP cache state
                    update
           Product: Networking
           Version: 2.5
    Kernel Version: 3.15
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: freeman.wang@broadcom.com
        Regression: No

Hi

We were testing high speed UDP throughput using iperf and found some out of
order packets which always happen immediately after an ARP exchange. Going
through the code and found that it is due to the wrong sequence of neighbour
state update and arq_queue flush.

At line 1161, the state is updated to the new state. And in line 1201, the
write lock is released. That is the reason why we saw this kind of sequence:

p1, p4, p2, p3, p5

If I did not misunderstand it, the arq_queue length is 3 by default. When the
ARP response is received, it will update the state and dequeue p1 first, then
the lock is dropped, so the thread trying to send p4 can squeeze in and send it
out since the state is 'connected'.

I think the solution should be moving the state update till the arp_queue is
fully drained.

Thanks
Freeman

1060 /* Generic update routine.
1061    -- lladdr is new lladdr or NULL, if it is not supplied.
1062    -- new    is new state.
1063    -- flags
1064         NEIGH_UPDATE_F_OVERRIDE allows to override existing lladdr,
1065                                 if it is different.
1066         NEIGH_UPDATE_F_WEAK_OVERRIDE will suspect existing "connected"
1067                                 lladdr instead of overriding it
1068                                 if it is different.
1069                                 It also allows to retain current state
1070                                 if lladdr is unchanged.
1071         NEIGH_UPDATE_F_ADMIN    means that the change is administrative.
1072
1073         NEIGH_UPDATE_F_OVERRIDE_ISROUTER allows to override existing
1074                                 NTF_ROUTER flag.
1075         NEIGH_UPDATE_F_ISROUTER indicates if the neighbour is known as
1076                                 a router.
1077
1078    Caller MUST hold reference count on the entry.
1079  */
1080
1081 int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
1082                  u32 flags)
1083 {
1084         u8 old;
1085         int err;
1086         int notify = 0;
1087         struct net_device *dev;
1088         int update_isrouter = 0;
1089
1090         write_lock_bh(&neigh->lock);
1091
1092         dev    = neigh->dev;
1093         old    = neigh->nud_state;
1094         err    = -EPERM;
1095
1096         if (!(flags & NEIGH_UPDATE_F_ADMIN) &&
1097             (old & (NUD_NOARP | NUD_PERMANENT)))
1098                 goto out;
1099
1100         if (!(new & NUD_VALID)) {
1101                 neigh_del_timer(neigh);
1102                 if (old & NUD_CONNECTED)
1103                         neigh_suspect(neigh);
1104                 neigh->nud_state = new;
1105                 err = 0;
1106                 notify = old & NUD_VALID;
1107                 if ((old & (NUD_INCOMPLETE | NUD_PROBE)) &&
1108                     (new & NUD_FAILED)) {
1109                         neigh_invalidate(neigh);
1110                         notify = 1;
1111                 }
1112                 goto out;
1113         }
1114
1115         /* Compare new lladdr with cached one */
1116         if (!dev->addr_len) {
1117                 /* First case: device needs no address. */
1118                 lladdr = neigh->ha;
1119         } else if (lladdr) {
1120                 /* The second case: if something is already cached
1121                    and a new address is proposed:
1122                    - compare new & old
1123                    - if they are different, check override flag
1124                  */
1125                 if ((old & NUD_VALID) &&
1126                     !memcmp(lladdr, neigh->ha, dev->addr_len))
1127                         lladdr = neigh->ha;
1128         } else {
1129                 /* No address is supplied; if we know something,
1130                    use it, otherwise discard the request.
1131                  */
1132                 err = -EINVAL;
1133                 if (!(old & NUD_VALID))
1134                         goto out;
1135                 lladdr = neigh->ha;
1136         }
1137
1138         if (new & NUD_CONNECTED)
1139                 neigh->confirmed = jiffies;
1140         neigh->updated = jiffies;
1141
1142         /* If entry was valid and address is not changed,
1143            do not change entry state, if new one is STALE.
1144          */
1145         err = 0;
1146         update_isrouter = flags & NEIGH_UPDATE_F_OVERRIDE_ISROUTER;
1147         if (old & NUD_VALID) {
1148                 if (lladdr != neigh->ha && !(flags &
NEIGH_UPDATE_F_OVERRIDE)) {
1149                         update_isrouter = 0;
1150                         if ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) &&
1151                             (old & NUD_CONNECTED)) {
1152                                 lladdr = neigh->ha;
1153                                 new = NUD_STALE;
1154                         } else
1155                                 goto out;
1156                 } else {
1157                         if (lladdr == neigh->ha && new == NUD_STALE &&
1158                             ((flags & NEIGH_UPDATE_F_WEAK_OVERRIDE) ||
1159                              (old & NUD_CONNECTED))
1160                             )
1161                                 new = old;
1162                 }
1163         }
1164
1165         if (new != old) {
1166                 neigh_del_timer(neigh);
1167                 if (new & NUD_IN_TIMER)
1168                         neigh_add_timer(neigh, (jiffies +
1169                                                 ((new & NUD_REACHABLE) ?
1170
neigh->parms->reachable_time :
1171                                                  0)));
1172                 neigh->nud_state = new;
1173                 notify = 1;
1174         }
1175
1176         if (lladdr != neigh->ha) {
1177                 write_seqlock(&neigh->ha_lock);
1178                 memcpy(&neigh->ha, lladdr, dev->addr_len);
1179                 write_sequnlock(&neigh->ha_lock);
1180                 neigh_update_hhs(neigh);
1181                 if (!(new & NUD_CONNECTED))
1182                         neigh->confirmed = jiffies -
1183                                       (NEIGH_VAR(neigh->parms,
BASE_REACHABLE_TIME) << 1);
1184                 notify = 1;
1185         }
1186         if (new == old)
1187                 goto out;
1188         if (new & NUD_CONNECTED)
1189                 neigh_connect(neigh);
1190         else
1191                 neigh_suspect(neigh);
1192         if (!(old & NUD_VALID)) {
1193                 struct sk_buff *skb;
1194
1195                 /* Again: avoid dead loop if something went wrong */
1196
1197                 while (neigh->nud_state & NUD_VALID &&
1198                        (skb = __skb_dequeue(&neigh->arp_queue)) != NULL) {
1199                         struct dst_entry *dst = skb_dst(skb);
1200                         struct neighbour *n2, *n1 = neigh;
1201                         write_unlock_bh(&neigh->lock);
1202
1203                         rcu_read_lock();
1204
1205                         /* Why not just use 'neigh' as-is?  The problem is
that
1206                          * things such as shaper, eql, and sch_teql can
end up
1207                          * using alternative, different, neigh objects to
output
1208                          * the packet in the output path.  So what we need
to do
1209                          * here is re-lookup the top-level neigh in the
path so
1210                          * we can reinject the packet there.
1211                          */
1212                         n2 = NULL;
1213                         if (dst) {
1214                                 n2 = dst_neigh_lookup_skb(dst, skb);
1215                                 if (n2)
1216                                         n1 = n2;
1217                         }
1218                         n1->output(n1, skb);
1219                         if (n2)
1220                                 neigh_release(n2);
1221                         rcu_read_unlock();
1222
1223                         write_lock_bh(&neigh->lock);
1224                 }
1225                 __skb_queue_purge(&neigh->arp_queue);
1226                 neigh->arp_queue_len_bytes = 0;
1227         }
1228 out:
1229         if (update_isrouter) {
1230                 neigh->flags = (flags & NEIGH_UPDATE_F_ISROUTER) ?
1231                         (neigh->flags | NTF_ROUTER) :
1232                         (neigh->flags & ~NTF_ROUTER);
1233         }
1234         write_unlock_bh(&neigh->lock);
1235
1236         if (notify)
1237                 neigh_update_notify(neigh);
1238
1239         return err;
1240 }
1241 EXPORT_SYMBOL(neigh_update);

--
You are receiving this mail because:
You are the assignee for the bug.
