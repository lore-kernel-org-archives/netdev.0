From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] ISDN: isdnloop:  C grammar issue,  '}' miss match 'if'
 and 'switch' statement.
Date: Wed, 03 Apr 2013 21:35:55 +0800
Message-ID: <515C303B.1040304@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: fengguang.wu@intel.com, isdn@linux-pingi.de,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:52007 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759440Ab3DCNg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 09:36:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

in drivers/isdn/isdnloop/isdnloop.c

  issue description:
    it is in function 'isdnloop_command'.
    it seems a C grammar issue for '}' miss match 'if' and 'switch' statement
    please check the line 1243, 1265, 1341.

  building:
    make allyesconfig, can not let it built.
    in menuconfig, we (at least for me) can not let ISDN_DRV_LOOP = 'y' or 'm'.
    is this module a waste module which should be deleted ?

  the related commit:
    commit 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2
    Author: Linus Torvalds <torvalds@ppc970.osdl.org>
    Date:   Sat Apr 16 15:20:36 2005 -0700


  please help check, thanks.

gchen.

1120 /*
1121  * Main handler for commands sent by linklevel.
1122  */
1123 static int
1124 isdnloop_command(isdn_ctrl *c, isdnloop_card *card)
1125 {
1126         ulong a;
1127         int i;
1128         char cbuf[60];
1129         isdn_ctrl cmd;
1130         isdnloop_cdef cdef;
1131 
1132         switch (c->command) {
1133         case ISDN_CMD_IOCTL:
1134                 memcpy(&a, c->parm.num, sizeof(ulong));
1135                 switch (c->arg) {
1136                 case ISDNLOOP_IOCTL_DEBUGVAR:
1137                         return (ulong) card;
1138                 case ISDNLOOP_IOCTL_STARTUP:
1139                         if (!access_ok(VERIFY_READ, (void *) a, sizeof(isdnloop_sdef)))
1140                                 return -EFAULT;
1141                         return (isdnloop_start(card, (isdnloop_sdef *) a));
1142                         break;
1143                 case ISDNLOOP_IOCTL_ADDCARD:
1144                         if (copy_from_user((char *)&cdef,
1145                                            (char *)a,
1146                                            sizeof(cdef)))
1147                                 return -EFAULT;
1148                         return (isdnloop_addcard(cdef.id1));
1149                         break;
1150                 case ISDNLOOP_IOCTL_LEASEDCFG:
1151                         if (a) {
1152                                 if (!card->leased) {
1153                                         card->leased = 1;
1154                                         while (card->ptype == ISDN_PTYPE_UNKNOWN)
1155                                                 schedule_timeout_interruptible(10);
1156                                         schedule_timeout_interruptible(10);
1157                                         sprintf(cbuf, "00;FV2ON\n01;EAZ1\n02;EAZ2\n");
1158                                         i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1159                                         printk(KERN_INFO
1160                                                "isdnloop: (%s) Leased-line mode enabled\n",
1161                                                CID);
1162                                         cmd.command = ISDN_STAT_RUN;
1163                                         cmd.driver = card->myid;
1164                                         cmd.arg = 0;
1165                                         card->interface.statcallb(&cmd);
1166                                 }
1167                         } else {
1168                                 if (card->leased) {
1169                                         card->leased = 0;
1170                                         sprintf(cbuf, "00;FV2OFF\n");
1171                                         i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1172                                         printk(KERN_INFO
1173                                                "isdnloop: (%s) Leased-line mode disabled\n",
1174                                                CID);
1175                                         cmd.command = ISDN_STAT_RUN;
1176                                         cmd.driver = card->myid;
1177                                         cmd.arg = 0;
1178                                         card->interface.statcallb(&cmd);
1179                                 }
1180                         }
1181                         return 0;
1182                 default:
1183                         return -EINVAL;
1184                 }
1185                 break;
1186         case ISDN_CMD_DIAL:
1187                 if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1188                         return -ENODEV;
1189                 if (card->leased)
1190                         break;
1191                 if ((c->arg & 255) < ISDNLOOP_BCH) {
1192                         char *p;
1193                         char dial[50];
1194                         char dcode[4];
1195 
1196                         a = c->arg;
1197                         p = c->parm.setup.phone;
1198                         if (*p == 's' || *p == 'S') {
1199                                 /* Dial for SPV */
1200                                 p++;
1201                                 strcpy(dcode, "SCA");
1202                         } else
1203                                 /* Normal Dial */
1204                                 strcpy(dcode, "CAL");
1205                         strcpy(dial, p);
1206                         sprintf(cbuf, "%02d;D%s_R%s,%02d,%02d,%s\n", (int) (a + 1),
1207                                 dcode, dial, c->parm.setup.si1,
1208                                 c->parm.setup.si2, c->parm.setup.eazmsn);
1209                         i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1210                 }
1211                 break;
1212         case ISDN_CMD_ACCEPTD:
1213                 if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1214                         return -ENODEV;
1215                 if (c->arg < ISDNLOOP_BCH) {
1216                         a = c->arg + 1;
1217                         cbuf[0] = 0;
1218                         switch (card->l2_proto[a - 1]) {
1219                         case ISDN_PROTO_L2_X75I:
1220                                 sprintf(cbuf, "%02d;BX75\n", (int) a);
1221                                 break;
1222 #ifdef CONFIG_ISDN_X25
1223                         case ISDN_PROTO_L2_X25DTE:
1224                                 sprintf(cbuf, "%02d;BX2T\n", (int) a);
1225                                 break;
1226                         case ISDN_PROTO_L2_X25DCE:
1227                                 sprintf(cbuf, "%02d;BX2C\n", (int) a);
1228                                 break;
1229 #endif
1230                         case ISDN_PROTO_L2_HDLC:
1231                                 sprintf(cbuf, "%02d;BTRA\n", (int) a);
1232                                 break;
1233                         }
1234                         if (strlen(cbuf))
1235                                 i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1236                         sprintf(cbuf, "%02d;DCON_R\n", (int) a);
1237                         i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1238                 }
1239                 break;
1240         case ISDN_CMD_ACCEPTB:
1241                 if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1242                         return -ENODEV;
1243                 if (c->arg < ISDNLOOP_BCH) {
1244                         a = c->arg + 1;
1245                         switch (card->l2_proto[a - 1]) {
1246                         case ISDN_PROTO_L2_X75I:
1247                                 sprintf(cbuf, "%02d;BCON_R,BX75\n", (int) a);
1248                                 break;
1249 #ifdef CONFIG_ISDN_X25
1250                         case ISDN_PROTO_L2_X25DTE:
1251                                 sprintf(cbuf, "%02d;BCON_R,BX2T\n", (int) a);
1252                                 break;
1253                         case ISDN_PROTO_L2_X25DCE:
1254                                 sprintf(cbuf, "%02d;BCON_R,BX2C\n", (int) a);
1255                                 break;
1256 #endif
1257                         case ISDN_PROTO_L2_HDLC:
1258                                 sprintf(cbuf, "%02d;BCON_R,BTRA\n", (int) a);
1259                                 break;
1260                         default:
1261                                 sprintf(cbuf, "%02d;BCON_R\n", (int) a);
1262                         }
1263                         printk(KERN_DEBUG "isdnloop writecmd '%s'\n", cbuf);
1264                         i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1265                         break;
1266                 case ISDN_CMD_HANGUP:
1267                         if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1268                                 return -ENODEV;
1269                         if (c->arg < ISDNLOOP_BCH) {
1270                                 a = c->arg + 1;
1271                                 sprintf(cbuf, "%02d;BDIS_R\n%02d;DDIS_R\n", (int) a, (int) a);
1272                                 i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1273                         }
1274                         break;
1275                 case ISDN_CMD_SETEAZ:
1276                         if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1277                                 return -ENODEV;
1278                         if (card->leased)
1279                                 break;
1280                         if (c->arg < ISDNLOOP_BCH) {
1281                                 a = c->arg + 1;
1282                                 if (card->ptype == ISDN_PTYPE_EURO) {
1283                                         sprintf(cbuf, "%02d;MS%s%s\n", (int) a,
1284                                                 c->parm.num[0] ? "N" : "ALL", c->parm.num);
1285                                 } else
1286                                         sprintf(cbuf, "%02d;EAZ%s\n", (int) a,
1287                                                 c->parm.num[0] ? c->parm.num : (u_char *) "0123456789");
1288                                 i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1289                         }
1290                         break;
1291                 case ISDN_CMD_CLREAZ:
1292                         if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1293                                 return -ENODEV;
1294                         if (card->leased)
1295                                 break;
1296                         if (c->arg < ISDNLOOP_BCH) {
1297                                 a = c->arg + 1;
1298                                 if (card->ptype == ISDN_PTYPE_EURO)
1299                                         sprintf(cbuf, "%02d;MSNC\n", (int) a);
1300                                 else
1301                                         sprintf(cbuf, "%02d;EAZC\n", (int) a);
1302                                 i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1303                         }
1304                         break;
1305                 case ISDN_CMD_SETL2:
1306                         if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1307                                 return -ENODEV;
1308                         if ((c->arg & 255) < ISDNLOOP_BCH) {
1309                                 a = c->arg;
1310                                 switch (a >> 8) {
1311                                 case ISDN_PROTO_L2_X75I:
1312                                         sprintf(cbuf, "%02d;BX75\n", (int) (a & 255) + 1);
1313                                         break;
1314 #ifdef CONFIG_ISDN_X25
1315                                 case ISDN_PROTO_L2_X25DTE:
1316                                         sprintf(cbuf, "%02d;BX2T\n", (int) (a & 255) + 1);
1317                                         break;
1318                                 case ISDN_PROTO_L2_X25DCE:
1319                                         sprintf(cbuf, "%02d;BX2C\n", (int) (a & 255) + 1);
1320                                         break;
1321 #endif
1322                                 case ISDN_PROTO_L2_HDLC:
1323                                         sprintf(cbuf, "%02d;BTRA\n", (int) (a & 255) + 1);
1324                                         break;
1325                                 case ISDN_PROTO_L2_TRANS:
1326                                         sprintf(cbuf, "%02d;BTRA\n", (int) (a & 255) + 1);
1327                                         break;
1328                                 default:
1329                                         return -EINVAL;
1330                                 }
1331                                 i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
1332                                 card->l2_proto[a & 255] = (a >> 8);
1333                         }
1334                         break;
1335                 case ISDN_CMD_SETL3:
1336                         if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
1337                                 return -ENODEV;
1338                         return 0;
1339                 default:
1340                         return -EINVAL;
1341                 }
1342         }
1343         return 0;
1344 }
